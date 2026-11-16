require "test_helper"

class GameFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(nickname: "admiral_jack", password: "password123")
    @player_two = User.create!(nickname: "admiral_two", password: "password123")
    @third_user = User.create!(nickname: "intruder", password: "password123")
  end

  # --- ТЕСТ 1 (обновлён под PvP): Создание игры и вход второго игрока ---
  test "successful game creation and opening dashboard" do
    cookies[:user_id] = @user.id.to_s

    get root_path
    assert_response :success

    assert_difference "Game.count", 1 do
      post games_path
    end

    assert_response :redirect
    follow_redirect!

    assert_response :success
    assert_select "h1.game-title", "⚔️ МОРСКОЙ БОЙ: PVP ⚔️"

    # Второй игрок заходит по ссылке-приглашению
    game = Game.last
    cookies[:user_id] = @player_two.id.to_s
    get join_game_path(game)
    assert_redirected_to game_path(game)
    assert_equal "active", game.reload.status
  end

  # --- ТЕСТ 2: Попытка неавторизованного гостя открыть экран боя ---
  test "guest should be handled safely when trying to open game" do
    game = Game.create!(player_one_id: @user.id, status: "active")

    get game_path(game)

    assert_response :success
    assert_select "span.nickname", "Гость"
  end

  # --- ТЕСТ 3 + НОВЫЙ ("Походили — отобразился ход") ---
  test "should record move and display it on the board" do
    cookies[:user_id] = @user.id.to_s
    game = Game.create!(
      player_one_id: @user.id,
      player_two_id: @player_two.id,
      current_turn_user_id: @user.id,
      status: "active"
    )

    assert_difference "Move.count", 1 do
      post game_moves_path(game), params: { x: 4, y: 4 }
    end

    assert_response :redirect
    follow_redirect!
    assert_response :success

    # Проверяем, что ход реально отобразился на поле боя (клетка получила свой ID со статусом)
    assert_select "div#cell-4-4"
  end

  # --- ТЕСТ 4: Невалидный ход (за границы поля и не в свою очередь) ---
  test "invalid move should be rejected and not saved" do
    game = Game.create!(
      player_one_id: @user.id,
      player_two_id: @player_two.id,
      current_turn_user_id: @user.id,
      status: "active"
    )
    cookies[:user_id] = @user.id.to_s

    # 1. Выстрел за пределы поля (x = 99)
    assert_no_difference "Move.count" do
      post game_moves_path(game), params: { x: 99, y: 5 }
    end
    assert_response :unprocessable_entity

    # 2. Второй игрок пытается походить не в свою очередь
    cookies[:user_id] = @player_two.id.to_s
    assert_no_difference "Move.count" do
      post game_moves_path(game), params: { x: 2, y: 2 }
    end
    assert_response :forbidden
  end

  # --- ТЕСТ 5: Гость или третий игрок пытается зайти третьим в матч ---
  test "guest or third player cannot join an already full match" do
    game = Game.create!(
      player_one_id: @user.id,
      player_two_id: @player_two.id,
      current_turn_user_id: @user.id,
      status: "active"
    )

    # 1. Неавторизованный гость переходит по ссылке приглашения
    cookies.delete(:user_id)
    get join_game_path(game)
    assert_redirected_to game_path(game)
    assert_equal @player_two.id, game.reload.player_two_id

    # 2. Третий зарегистрированный пользователь пытается войти в занятую комнату
    cookies[:user_id] = @third_user.id.to_s
    get join_game_path(game)
    assert_redirected_to game_path(game)
    assert_equal @player_two.id, game.reload.player_two_id
  end
end

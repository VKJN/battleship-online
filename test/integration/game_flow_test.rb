require "test_helper"

class GameFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(nickname: "admiral_jack", password: "password123")
  end

  # ТЕСТ 1
  test "successful game creation and opening dashboard" do
    # Имитирует, что пользователь авторизован
    cookies[:user_id] = @user.id.to_s

    # Заходит на главную страницу приложения
    get root_path
    assert_response :success

    # Отправляет форму старта матча 
    assert_difference "Game.count", 1 do
      post games_path
    end

    # 3. Проверяем, что сервер делает перенаправление на страницу боя
    assert_response :redirect
    follow_redirect!

    # 4. Проверяем, что экран боя успешно открылся
    assert_response :success
    assert_select "h1.game-title", "⚔️ ИДЁТ СРАЖЕНИЕ ⚔️"
  end

  # ТЕСТ 2: Попытка неавторизованного зайти на бой
  test "guest should be handled safely when trying to open game" do
    game = Game.create!(player_one_id: @user.id, status: "active")

    get game_path(game)

    # Проверяем, что страница успешно открылась без ошибки 500 и на ней написано "Гость"
    assert_response :success
    assert_select "span.nickname", "Гость"
  end

  # ТЕСТ 3: Попытка сделать ход в чужую игру
  test "should record move via post request in game flow" do
    cookies[:user_id] = @user.id.to_s
    game = Game.create!(player_one_id: @user.id, status: "active")

    assert_difference "Move.count", 1 do
      post game_moves_path(game), params: { x: 4, y: 4 }
    end

    # Проверка на запись хода
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
end

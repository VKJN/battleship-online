require "test_helper"

class MoveTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(nickname: "admiral_test", password: "password123")
    @game = Game.create!(player_one_id: @user.id, status: "active")
  end

  # Проверка, что правильный ход создаётся
  test "should be valid with correct coordinates" do
    move = Move.new(game: @game, user: @user, x: 5, y: 5)
    assert move.valid?, "Ход с координатами 5,5 должен быть валидным"
  end

  # Проверка защиты от выхода за границы
  test "should be invalid if coordinates out of bounds" do
    move = Move.new(game: @game, user: @user, x: 11, y: 5)
    assert_not move.valid?, "Ход с координатой X=11 должен быть заблокирован"
    assert_includes move.errors[:x].to_s, "в пределах от 1 до 10"
  end

  # Проверка защиты от повторного выстрела в ту же клетку
  test "should be invalid if cell already attacked" do
    Move.create!(game: @game, user: @user, x: 3, y: 3)
    duplicate_move = Move.new(game: @game, user: @user, x: 3, y: 3)
    
    assert_not duplicate_move.valid?, "Повторный ход в клетку 3,3 должен быть заблокирован"
    assert_includes duplicate_move.errors[:base], "В эту клетку уже стреляли"
  end
end

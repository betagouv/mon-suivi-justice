class SteeringPolicy < Struct.new(:user, :steering)
  def steering?
    user.admin?
  end
end

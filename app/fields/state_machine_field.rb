require 'administrate/field/base'

class StateMachineField < Administrate::Field::Base
  def to_s
    data
  end

  def permitted_transitions
    resource.state_transitions.map(&:to_name)
  end
end

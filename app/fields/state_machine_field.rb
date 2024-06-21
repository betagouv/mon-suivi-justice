require 'administrate/field/base'

class StateMachineField < Administrate::Field::Base
  def to_s
    data
  end

  def permitted_transitions
    [resource.human_state_name] + (resource.state_paths.to_states & %i[accepted refused]).map { |state| OrganizationDivestment.human_state_name(state) }
  end
end

class SlotTypesAgendaLinkJob < ApplicationJob
  def perform
    # Migration handled SlotType duplication for each agenda. All slots were destroyed in the process.
    # Re-launch Slot creation factory to re-seed new slot :
    SlotCreationJob.perform_later oneshot: true
  end
end

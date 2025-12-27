class Public::Professors::Journals::JournalEntriesController < ApplicationController
  layout "public"

  def show
    @teacher = Teacher.find(params[:professor_id])
    redirect_to root_path, alert: "This profile is not available." unless @teacher.show_on_contributors

    @journal = Journal.find(params[:journal_id])
    @journal_entry = @journal.journal_entries.where(id: params[:id]).first

    redirect_to root_path and return unless @journal_entry
  end
end

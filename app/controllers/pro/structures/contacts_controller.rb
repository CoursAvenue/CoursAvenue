# Controller used when structure import contacts.
class Pro::Structures::ContactsController < Pro::ProController

  def callback
    @contacts = request.env['omnicontacts.contacts'].reject do |contact|
      contact[:emails].first.nil?
    end
    @contacts.map! do |contact|
      { email: contact[:emails].map{ |emails| emails[:email] }.join(', '), name: contact[:name] }
    end
    render layout: 'empty_body'
  end

  def failure
    @error_message = "Erreur: Veuillez rééssayer."
    respond_to do |format|
      format.json { render json: { message: @error_message }, status: 422 }
      format.html { render layout: 'empty_body' }
    end
  end
end

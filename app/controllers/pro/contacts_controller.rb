class Pro::ContactsController < Pro::ProController
  def callback
    @contacts = request.env['omnicontacts.contacts'].flat_map { |contact| contact[:emails] }
  end

  def failure
    @error_message = "Erreur: Veuillez rééssayer."
    respond_to do |format|
      format.json { render json: { message: @error_message }, status: 422 }
      format.html { render }
    end
  end
end

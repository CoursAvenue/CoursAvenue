class Pro::ContactsController < Pro::ProController
  def callback
    @contacts = request.env['omnicontacts.contacts'].flat_map { |contact| contact[:emails] }
    @contacts << { email: 'aaaa@aaaa.fr' }
  end

  def failure
    error_message = ""
    respond_to do |format|
      format.json { render json: { message: error_message }, status: 422 }
      format.html { redirect_to recommendations_pro_structure_path, flash: { message: message } }
    end
  end
end

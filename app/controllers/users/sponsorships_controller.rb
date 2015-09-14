class Users::SponsorshipsController < Pro::ProController

  layout 'user_profile'

  before_action :authenticate_user!
  load_and_authorize_resource :user

  # GET eleves/:user_id/parrainages
  def index
    @sponsorships = @user.sponsorships
  end

  # GET eleves/:user_id/parrainaged/new
  def new
    @discount = Sponsorship.discount_amount_for_sponsorer(@user)
  end

  def create
    params[:emails] ||= ''
    regexp = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
    emails = params[:emails].scan(regexp).uniq
    text = '<div class="p">' + params[:text].gsub(/\r\n\r\n/, '</div><div class="p">').gsub(/\r\n/, '<br>') + '</div>'

    emails.each do |_email|
      user = User.create_or_find_from_email(_email)
      sponsorship = @user.sponsorships.create(sponsored_user: user)

      UserMailer.delay(queue: 'mailers').sponsor_user(@user, _email, sponsorship_url(sponsorship.promo_code, subdomain: 'www'), text)
    end

    respond_to do |format|
      format.html { redirect_to user_sponsorships_path(@user), notice: (params[:emails].present? ? 'Vos amis ont bien été invités.' : nil) }
    end
  end

  protected

  def layout_locals
    { hide_menu: true }
  end
end

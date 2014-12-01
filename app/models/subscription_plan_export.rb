class SubscriptionPlanExport < ActiveRecord::Base
  attr_accessible :url

  after_create :upload_file

  private

  # Upload Subscription Plans export to S3 and set set the url
  #
  # @return
  def upload_file
    subscriptions = SubscriptionPlan.where(SubscriptionPlan.arel_table[:expires_at].gt(Date.today))

    package = Axlsx::Package.new
    workbook = package.workbook
    workbook.add_worksheet(name: 'Suivi Premium') do |sheet|
      sheet.add_row [
        "Nom du Profil",
        "Type abonnement",
        "Date 1ere subscription",
        "Nombre de jours aprés renouvellement",
        "Nombre d'impressions",
        "Nombre de vue",
        "Nombre de actions",
        "Nombre de demande d'infos",
        "Nombre de de tel",
        "Nombre de de clic web",
        "Code couleur",
        "FB actif",
        "AdWords actif",
        "Commentaires",
        "Nombre d'impressions depuis le début",
        "Nombre de vue depuis le début",
        "Nombre de actions depuis le début",
        "Nombre de demande d'infos depuis le début",
        "Nombre de de tel depuis le début",
        "Nombre de de clic web depuis le début"
      ]
      subscriptions.each do |subscription|
        renewed_date = subscription.renewed_at.present? ? subscription.renewed_at.to_datetime : subscription.created_at
        since_date = subscription.renewed_at.present? ? subscription.renewed_at : subscription.created_at.to_date

        actions = Metric.action_count(subscription.structure, since_date)
        conversations = subscription.structure.main_contact.mailbox.conversations.where(mailboxer_label_id: Mailboxer::Label::INFORMATION.id).where(Mailboxer::Conversation.arel_table[:created_at].gt(since_date)).count

        sheet.add_row [
          subscription.structure.name,
          SubscriptionPlan::PLAN_TYPE_DESCRIPTION[subscription.plan_type],
          I18n.l(subscription.created_at.to_date),
          (Time.now - renewed_date).to_i / 1.day,
          Metric.impression_count(subscription.structure, since_date),
          Metric.view_count(subscription.structure, since_date),
          actions,
          conversations,
          Metric.telephone_count(subscription.structure, since_date),
          Metric.website_count(subscription.structure, since_date),
          Metric.score(actions, conversations),
          subscription.facebook_active.present? ? I18n.t(subscription.facebook_active.class) : 'Non',
          subscription.adwords_active.present? ? I18n.t(subscription.adwords_active.class) : 'Non',
          subscription.bo_comments.present? ? subscription.bo_comments.to_s : '',
          Metric.impression_count(subscription.structure),
          Metric.view_count(subscription.structure),
          Metric.action_count(subscription.structure),
          subscription.structure.main_contact.mailbox.conversations.where(mailboxer_label_id: Mailboxer::Label::INFORMATION.id).count,
          Metric.telephone_count(subscription.structure),
          Metric.website_count(subscription.structure)
        ]
      end
    end

    stream = package.to_stream()

    s3 = AWS::S3.new
    file = s3.buckets[ENV["AWS_BUCKET"]].objects["subscription_plan/export_#{Time.now.to_s}.xls"]
    file.write(content_length: stream.size) do |buffer, bytes|
      buffer.write(stream.read(bytes))
    end

    self.url = file.url_for(:read, expires: 100.years.to_i ).to_s
    self.save
    SuperAdminMailer.subscription_plan_export_uploaded_to_s3(self).deliver
  end
  handle_asynchronously :upload_file

end

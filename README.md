### Rbenv & Pow

\# ~/.powconfig
`export PATH=$(rbenv root)/shims:$(rbenv root)/bin:$PATH`

## Dependencies / Gems

### For Will_paginate
A custom renderer has been created in lib/

### SCSS
Inuit.css
Compass for mixins

### Add remote branch for Heroku
`git remote add heroku git@heroku.com:leboncours.git`


### Heroku

[Using Labs: user-env-compile](https://devcenter.heroku.com/articles/labs-user-env-compile#use-case)

    heroku labs:enable user-env-compile -a

### Paperclip

Dependencies: imagemagick

### For Heroku

`heroku config:add AWS_BUCKET=bucket_name`
`heroku config:add AWS_ACCESS_KEY_ID=`
`heroku config:add AWS_SECRET_ACCESS_KEY=`

### [Solr sunspot](https://github.com/sunspot/sunspot#readme)
Commands
`rake sunspot:solr:run`

On heroku
`heroku run rake sunspot:solr:start`
`heroku run rake sunspot:solr:stop`
`heroku run rake sunspot:reindex`


### Git
Remove local branch
`git branch -D branch_name`
Remove remote branch
`git push origin --delete branch_name`

### Cities
http://download.geonames.org/export/zip/

### Sitemap
RAILS_ENV=production rake sitemap:create


### Tests
RAILS_ENV=test rake sunspot:solr:start

# Recovering a dump
createdb -h localhost -O postgres -U postgres coursavenue_development
pg_restore --host localhost --port 5432 --username "postgres" --dbname "coursavenue_development" --role "qjppevpnykjrmw" --no-password  --verbose "/Users/Nima/Downloads/a065.dump"


Structure.all.each{|s| s.update_column(:comments_count, s.all_comments.length)}





 :id => 466,
                                  :structure_type => nil,
                                            :name => "Théâtre de Buée Séverine Batier",
                                            :info => nil,
                               :registration_info => nil,
                      :gives_professional_courses => nil,
                                         :website => "http://www.theatredebuee.fr",
                                    :phone_number => nil,
                             :mobile_phone_number => nil,
                                   :contact_email => "theatredebuee@orange.fr",
                        :accepts_holiday_vouchers => false,
                      :accepts_ancv_sports_coupon => false,
                         :accepts_leisure_tickets => false,
                           :accepts_afdas_funding => false,
                             :accepts_dif_funding => false,
                             :accepts_cif_funding => false,
                           :has_registration_form => nil,
                 :needs_photo_id_for_registration => nil,
                  :needs_id_copy_for_registration => nil,
      :needs_medical_certificate_for_registration => nil,
    :needs_insurance_attestation_for_registration => nil,
                                      :created_at => Sun, 30 Jun 2013 16:12:33 UTC +00:00,
                                      :updated_at => Sun, 30 Jun 2013 16:20:51 UTC +00:00,
                                            :slug => "theatre-de-buee-severine-batier",
                                          :street => "8 rue du général renault",
                                        :zip_code => "75011",
                                     :description => "",
                                           :siret => nil,
                             :tva_intracom_number => nil,
                                :structure_status => nil,
                      :billing_contact_first_name => nil,
                       :billing_contact_last_name => nil,
                    :billing_contact_phone_number => nil,
                           :billing_contact_email => nil,
                                       :bank_name => nil,
                                       :bank_iban => nil,
                                        :bank_bic => nil,
                                         :city_id => 177568,
                                          :active => true,
                                 :pricing_plan_id => nil,
                        :has_validated_conditions => false,
                                    :validated_by => nil,
                                :cancel_condition => nil,
                          :modification_condition => nil,
                                      :deleted_at => nil,
                                        :latitude => nil,
                                       :longitude => nil,
                                           :gmaps => nil,
                                 :image_file_name => "Paris-20130509-00554.jpg",
                              :image_content_type => "image/jpeg",
                                 :image_file_size => 71688,
                                :image_updated_at => Sun, 30 Jun 2013 16:20:50 UTC +00:00,
                                 :subjects_string => "Théâtre,theatre",
                          :parent_subjects_string => "Spectacle / Théâtre,arts-du-spectacle",
                                          :rating => nil,
                                  :comments_count => 0,
                                    :facebook_url => ""



#<Place:0x007fabcc985ad8> {
                          :id => 661,
                        :name => "Adresse principale",
                      :street => "8 rue du général renault",
                        :info => nil,
                    :zip_code => "75011",
         :has_handicap_access => nil,
                     :nb_room => nil,
                :contact_name => nil,
               :contact_phone => nil,
        :contact_mobile_phone => nil,
               :contact_email => "theatredebuee@orange.fr",
                :structure_id => 466,
                     :city_id => 177568,
                  :created_at => Sun, 30 Jun 2013 16:12:33 UTC +00:00,
                  :updated_at => Sun, 30 Jun 2013 16:12:33 UTC +00:00,
                    :latitude => 48.8612534,
                   :longitude => 2.3784498,
                       :gmaps => true,
              :has_cloackroom => false,
                :has_internet => false,
        :has_air_conditioning => false,
           :has_swimming_pool => false,
            :has_free_parking => false,
                 :has_jacuzzi => false,
                   :has_sauna => false,
                :has_daylight => false,
                        :slug => "theatre-de-buee-severine-batier",
             :image_file_name => nil,
          :image_content_type => nil,
             :image_file_size => nil,
            :image_updated_at => nil,
       :thumb_image_file_name => nil,
    :thumb_image_content_type => nil,
       :thumb_image_file_size => nil,
      :thumb_image_updated_at => nil,
                  :deleted_at => nil,
                 :description => "",
             :subjects_string => "Théâtre,theatre",
      :parent_subjects_string => "Spectacle / Théâtre,arts-du-spectacle"


#<Admin:0x007fabc3b48400> {
                          :id => 143,
                       :email => "theatredebuee@orange.fr",
          :encrypted_password => "$2a$10$fyeRos.VgtSCPHk.djeHIuP8MD.s3UQAtdZUrzoPYb2ieWYxK/odW",
        :reset_password_token => nil,
      :reset_password_sent_at => nil,
         :remember_created_at => nil,
               :sign_in_count => 1,
          :current_sign_in_at => Sun, 30 Jun 2013 16:15:14 UTC +00:00,
             :last_sign_in_at => Sun, 30 Jun 2013 16:15:14 UTC +00:00,
          :current_sign_in_ip => "83.114.160.102",
             :last_sign_in_ip => "83.114.160.102",
                  :created_at => Sun, 30 Jun 2013 16:12:59 UTC +00:00,
                  :updated_at => Sun, 30 Jun 2013 16:15:14 UTC +00:00,
                 :super_admin => false,
            :invitation_token => nil,
          :invitation_sent_at => nil,
      :invitation_accepted_at => nil,
            :invitation_limit => nil,
               :invited_by_id => nil,
             :invited_by_type => nil,
                :structure_id => 466,
                    :civility => nil,
                :phone_number => nil,
         :mobile_phone_number => nil,
                      :active => true,
                        :role => nil,
    :management_software_used => nil,
                  :is_teacher => nil,
                        :name => nil,
          :confirmation_token => nil,
                :confirmed_at => Sun, 30 Jun 2013 16:15:14 UTC +00:00,
        :confirmation_sent_at => Sun, 30 Jun 2013 16:12:59 UTC +00:00,
           :unconfirmed_email => nil

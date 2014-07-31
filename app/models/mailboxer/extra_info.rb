class Mailboxer::ExtraInfo < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, short_name: 'inscription'  , name: 'mailboxer.extra_info.inscription'   },
    { id: 2, short_name: 'planning_info', name: 'mailboxer.extra_info.planning_info' },
    { id: 3, short_name: 'be_called'    , name: 'mailboxer.extra_info.be_called'     },
    { id: 4, short_name: 'more_info'    , name: 'mailboxer.extra_info.more_info'     }
  ]
  enum_accessor :short_name
end

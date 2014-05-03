class Mailboxer::Label < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, short_name: 'Information' , name: 'mailboxer.label.information' , color: 'yellow'    },
    { id: 2, short_name: 'Comment'     , name: 'mailboxer.label.comment'     , color: 'green'    },
    { id: 3, short_name: 'Conversation', name: 'mailboxer.label.conversation', color: 'gray'    }
  ]
  enum_accessor :short_name
end

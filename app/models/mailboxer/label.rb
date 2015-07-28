class Mailboxer::Label < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, short_name: 'Information',     name: 'mailboxer.label.information',     color: 'blue'    },
    { id: 2, short_name: 'Comment',         name: 'mailboxer.label.comment',         color: 'green'   },
    { id: 3, short_name: 'Conversation',    name: 'mailboxer.label.conversation',    color: 'gray'    },
    { id: 4, short_name: 'Request',         name: 'mailboxer.label.request',         color: 'orange'  },
    { id: 5, short_name: 'public_question', name: 'mailboxer.label.public_question', color: 'orange'  }
  ]
  enum_accessor :short_name
end

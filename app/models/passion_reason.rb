class PassionReason < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, name: 'passions.reasons.discover'           },
    { id: 2, name: 'passions.reasons.participate'        },
    { id: 3, name: 'passions.reasons.looking_for_someone'},
    { id: 4, name: 'passions.reasons.share_passion'      },
    { id: 5, name: 'passions.reasons.nothing'            },
    { id: 6, name: 'passions.reasons.gonna_stop'         },
    { id: 7, name: 'passions.reasons.other'              }
  ]
end

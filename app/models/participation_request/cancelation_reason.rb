class ParticipationRequest::CancelationReason < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1 , type: 'structure', hidden: false,
      name: 'participation_request.cancelation_reason.structures.course_is_full' },
    { id: 2 , type: 'structure', hidden: false,
      name: 'participation_request.cancelation_reason.structures.dont_give_this_course_anymore' },
    { id: 3 , type: 'structure', hidden: false,
      name: 'participation_request.cancelation_reason.structures.dont_take_new_students' },
    { id: 4 , type: 'structure', hidden: false,
      name: 'participation_request.cancelation_reason.structures.request_already_treated' },
    { id: 5 , type: 'structure', hidden: false,
      name: 'participation_request.cancelation_reason.structures.fake_request' },
    { id: 6 , type: 'structure', hidden: true,
      name: 'participation_request.cancelation_reason.structures.do_not_trust' },
    { id: 7 , type: 'structure', hidden: true,
      name: 'participation_request.cancelation_reason.structures.other' },
    { id: 8 , type: 'user'     , hidden: false,
      name: 'participation_request.cancelation_reason.users.impediment' },
    { id: 9 , type: 'user'     , hidden: false,
      name: 'participation_request.cancelation_reason.users.already_requested' },
    { id: 10, type: 'user'     , hidden: false,
      name: 'participation_request.cancelation_reason.users.found_better' },
    { id: 11, type: 'user'     , hidden: false,
      name: 'participation_request.cancelation_reason.users.not_interested_anymore' },
    { id: 12, type: 'user'     , hidden: false,
      name: 'participation_request.cancelation_reason.users.sick' },
    { id: 13, type: 'user'     , hidden: true,
      name: 'participation_request.cancelation_reason.users.do_not_trust' },
    { id: 14, type: 'user'     , hidden: true,
      name: 'participation_request.cancelation_reason.users.other' },
    { id: 15 , type: 'structure',hidden: false,
      name: 'participation_request.cancelation_reason.structures.account_deleted' },
    { id: 16 , type: 'users',    hidden: false,
      name: 'participation_request.cancelation_reason.users.account_deleted' }
  ]

end

class ParticipationRequest::CancelationReason < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, name: 'participation_request.cancelation_reason.course_is_full' },
    { id: 2, name: 'participation_request.cancelation_reason.dont_give_this_course_anymore' },
    { id: 3, name: 'participation_request.cancelation_reason.dont_take_new_students' },
    { id: 4, name: 'participation_request.cancelation_reason.request_already_treated' },
    { id: 5, name: 'participation_request.cancelation_reason.fake_request' },
    { id: 6, name: 'participation_request.cancelation_reason.do_not_trust' },
    { id: 7, name: 'participation_request.cancelation_reason.other' }
  ]

end

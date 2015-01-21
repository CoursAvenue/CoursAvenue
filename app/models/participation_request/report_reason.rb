class ParticipationRequest::ReportReason < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1 , type: 'structure', name: 'participation_request.report_reason.structures.include_blank' },
    { id: 2 , type: 'structure', name: 'participation_request.report_reason.structures.no_show' },
    { id: 3 , type: 'structure', name: 'participation_request.report_reason.structures.wrong_audience' },
    { id: 4 , type: 'structure', name: 'participation_request.report_reason.structures.disrespectful' },
    { id: 5 , type: 'structure', name: 'participation_request.report_reason.structures.free_course_overuse' },
    { id: 6 , type: 'structure', name: 'participation_request.report_reason.structures.other' },
    { id: 7 , type: 'user'     , name: 'participation_request.report_reason.users.no_show' },
    { id: 8 , type: 'user'     , name: 'participation_request.report_reason.users.wrong_inscription_details' },
    { id: 9 , type: 'user'     , name: 'participation_request.report_reason.users.wrong_course_description' },
    { id: 10, type: 'user'     , name: 'participation_request.report_reason.users.disrespectful' },
    { id: 11, type: 'user'     , name: 'participation_request.report_reason.users.wrong_pricing' },
    { id: 12, type: 'user'     , name: 'participation_request.report_reason.users.other' }
  ]
end




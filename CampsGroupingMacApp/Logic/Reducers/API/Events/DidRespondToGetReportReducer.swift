import Foundation

extension APIEventReducer {
    enum DidRespondToGetReportReducer {
        static func handleEvent(
            result: Result<Report, CampsGroupingAPIError>,
            camp: CampInfo,
            fetchID: UUID,
            state: inout GrouperState
        ) -> [GrouperAction] {
            switch result {
            case .success(let report):
                didGetReport(
                    report: report,
                    camp: camp,
                    fetchID: fetchID,
                    state: &state
                )
            case .failure(let error):
                didFailToGetReport(
                    error: error,
                    camp: camp,
                    fetchID: fetchID,
                    state: &state
                )
            }
        }

        static func didGetReport(
            report: Report,
            camp: CampInfo,
            fetchID: UUID,
            state: inout GrouperState
        ) -> [GrouperAction] {
            // TODO: handle report
            []
        }

        static func didFailToGetReport(
            error: CampsGroupingAPIError,
            camp: CampInfo,
            fetchID: UUID,
            state: inout GrouperState
        ) -> [GrouperAction] {
            // TODO: handle error
            []
        }
    }
}

import Foundation

extension APIEventReducer {
    enum DidRespondToUpdateReportFormatReducer {
        static func handleEvent(
            result: UpdateReportFormatResult,
            requestData: UpdateReportFormatData,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.activeFetches.remove(networkCall)
            switch result {
            case .success:
                state.camps = state.camps.map({ camp in
                    if camp.info.eventNumber == requestData.campSettings.report.campEventNumber {
                        var updated = camp
                        updated.campSettings?.reportSettingsOnRecord = requestData.campSettings.report.reportFieldSettings
                        return updated
                    } else {
                        return camp
                    }
                })

                return [state.beginGetReportFormatForCamp(campSettings: requestData.campSettings)]
            case .failure(let error):
                state.errors = state.errors.filter { error in
                    if case .updateReportFormat = error {
                        false
                    } else {
                        true
                    }
                }

                state.errors.insert(.updateReportFormat(error: error, networkCall: networkCall))
                return []
            }
        }
    }
}

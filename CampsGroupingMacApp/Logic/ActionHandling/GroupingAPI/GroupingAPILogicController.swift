import Foundation
import SwiftCSV

protocol GroupingAPILogicControllerProtocol {
    func getCampReports(
        requestData: GetCampReportsData,
        networkCall: NetworkCall,
        completion: @escaping (GetCampReportsResult) -> Void
    )
    func getReport(
        requestData: GetReportData,
        networkCall: NetworkCall,
        completion: @escaping (GetReportResult) -> Void
    )
    func getReportFormat(
        requestData: GetReportFormatData,
        networkCall: NetworkCall,
        completion: @escaping (GetReportFormatResult) -> Void
    )
    func getCamperSettings(
        requestData: GetCamperSettingsData,
        networkCall: NetworkCall,
        completion: @escaping (GetCamperSettingsResult) -> Void
    )
    func setReport(
        requestData: SetReportData,
        networkCall: NetworkCall,
        completion: @escaping (SetReportResult) -> Void
    )
    func updateReportFormat(
        requestData: UpdateReportFormatData,
        networkCall: NetworkCall,
        completion: @escaping (UpdateReportFormatResult) -> Void
    )
    func updateCamperAssigments(
        requestData: UpdateCamperAssigmentsData,
        networkCall: NetworkCall,
        completion: @escaping (SetCamperAssigmentsResult) -> Void
    )
}

class GroupingAPILogicController: GroupingAPILogicControllerProtocol {
    let communicator: CampGroupingAPICommunicatorProtocol

    init(
        communicator: CampGroupingAPICommunicatorProtocol = CampGroupingAPICommunicator()
    ) {
        self.communicator = communicator
    }

    func getCampReports(
        requestData: GetCampReportsData,
        networkCall: NetworkCall,
        completion: @escaping (GetCampReportsResult) -> Void
    ) {
        communicator.get(requestData: requestData) { result in
            switch result {
            case .success(let success):
                completion(
                    .success(
                        success.data.map { addressDTO in
                            ReportAddress(
                                campID: addressDTO.eventID,
                                reportID: addressDTO.reportID
                            )
                        }
                    )
                )
            case .failure(let failure):
                completion(
                    .failure(
                        CampsGroupingAPIError.fromNSError(
                            failure,
                            endpoint: requestData.endpoint
                        )
                    )
                )
            }
        }
    }
    
    func getReport(requestData: GetReportData, networkCall: NetworkCall, completion: @escaping (GetReportResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let url = requestData.endpoint.url
                if let csv = try? CSV<Named>(url: url) {
                    let report  = Report(
                        csv: csv,
                        campID: requestData.campSettings.report.campEventNumber
                    )

                    DispatchQueue.main.async {
                        completion(.success(report))
                    }

                } else {
                    throw NSError(domain: "csv", code: 404)
                }
            } catch {
                let nsError = error as NSError
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            CampsGroupingAPIError.fromNSError(
                                nsError,
                                endpoint: requestData.endpoint
                            )
                        )
                    )
                }
            }
        }
    }
    
    func getReportFormat(requestData: GetReportFormatData, networkCall: NetworkCall, completion: @escaping (GetReportFormatResult) -> Void) {
        communicator.get(requestData: requestData) { result in
            switch result {
            case .success(let success):
                completion(
                    .success(
                        success.data.fieldSettings.map(
                            { dto in
                                ReportFieldSetting(
                                    fieldName: dto.fieldName.desanitized,
                                    fieldType: ReportFieldType(rawValue: dto.fieldType)
                                    ?? .string,
                                    visable: dto.visable,
                                    showInTable: dto.searchable,
                                    includeInGrouping: dto.useToGroup,
                                    handleDirectly: dto.handleDirectly,
                                    isRegistrantData: dto.primary
                                )
                            }
                        )
                    )
                )
            case .failure(let failure):
                completion(
                    .failure(
                        CampsGroupingAPIError.fromNSError(
                            failure,
                            endpoint: requestData.endpoint
                        )
                    )
                )
            }
        }
    }
    
    func getCamperSettings(
        requestData: GetCamperSettingsData,
        networkCall: NetworkCall,
        completion: @escaping (GetCamperSettingsResult) -> Void
    ) {
        communicator.get(requestData: requestData) { result in
            switch result {
            case .success(let success):
                completion(
                    .success(
                        success.data.assignments.compactMap { dto -> CamperSetting? in
                            guard let camperID: Int = Int(dto.camperID) else { return nil }

                            let associatedArray: [String] = dto.associatedCampers
                                .components(separatedBy: ",")

                            let associatedCamperIDs = associatedArray.compactMap { stringID in
                                Int(stringID)
                            }

                            return CamperSetting(
                                camperID: camperID,
                                attendeeID: dto.attendeeID,
                                groupNumber: dto.groupNumber,
                                groupID: dto.groupID,
                                associatedCampers: associatedCamperIDs,
                                status: dto.status,
                                notes: dto.notes
                            )
                        }
                    )
                )
            case .failure(let failure):
                completion(.failure(.fromNSError(failure, endpoint: requestData.endpoint)))
            }
        }
    }
    
    func setReport(requestData: SetReportData, networkCall: NetworkCall, completion: @escaping (SetReportResult) -> Void) {
        communicator.set(requestData: requestData) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let failure):
                completion(.failure(.fromNSError(failure, endpoint: requestData.endpoint)))
            }
        }
    }
    
    func updateReportFormat(requestData: UpdateReportFormatData, networkCall: NetworkCall, completion: @escaping (UpdateReportFormatResult) -> Void) {
        communicator.set(requestData: requestData) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let failure):
                completion(.failure(.fromNSError(failure, endpoint: requestData.endpoint)))
            }
        }
    }
    
    func updateCamperAssigments(requestData: UpdateCamperAssigmentsData, networkCall: NetworkCall, completion: @escaping (SetCamperAssigmentsResult) -> Void) {
        communicator.update(requestData: requestData) { result in
            switch result {
            case .success(let result):
                completion(
                    .success(
                        result.data.assignments.compactMap { dto -> CamperSetting? in
                            guard let camperID: Int = Int(dto.camperID) else { return nil }

                            let associatedArray: [String] = dto.associatedCampers
                                .components(separatedBy: ",")

                            let associatedCamperIDs = associatedArray.compactMap { stringID in
                                Int(stringID)
                            }

                            return CamperSetting(
                                camperID: camperID,
                                attendeeID: dto.attendeeID,
                                groupNumber: dto.groupNumber,
                                groupID: dto.groupID,
                                associatedCampers: associatedCamperIDs,
                                status: dto.status,
                                notes: dto.notes
                            )
                        }
                    )
                )            
            case .failure(let failure):
                completion(.failure(.fromNSError(failure, endpoint: requestData.endpoint)))
            }
        }
    }
}

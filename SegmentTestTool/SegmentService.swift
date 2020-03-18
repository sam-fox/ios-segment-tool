//
//  SegmentService.swift
//  SegmentTestTool
//
//  Created by Michael Rack on 3/16/20.
//  Copyright © 2020 Willow Tree Apps. All rights reserved.
//

import Foundation

class SegmentService {
    let client = CharlesClient()
    let decoder = JSONDecoder()
    
    func dataToProxyLogIn(from data: Data, completion: @escaping ([ProxyLogElement]) -> Void) {
        guard let log = try? self.decoder.decode([ProxyLogElement].self, from: data) else { return }
        completion(log)
    }
    
    func segmentCallsIn(from log: [ProxyLogElement], completion: @escaping ([Segment]) -> Void) {
        var segmentList: [Segment] = []
        for element in log {
            if element.host == "api.segment.io" {
                let segmentString = element.request?.body?.text
                let segmentData = segmentString!.data(using: .utf8)!
                let segment = try! self.decoder.decode(Segment.self, from: segmentData)
                segmentList.append(segment)
            }
        }
        completion(segmentList)
    }
    
    func matchingSegmentBatchesIn(completion: @escaping ([BatchElement]) -> Void, from segmentList: [Segment], expectedCallType: String, expectedPageType: String) {
        var expectedBatchElements: [BatchElement] = []
        for segmentElement in segmentList {
            let batch = segmentElement.batch
            for batchElement in batch ?? [] {
                if batchElement.type == expectedCallType && batchElement.properties?.pageType == expectedPageType {
                    expectedBatchElements.append(batchElement)
                }
            }
        }
        completion(expectedBatchElements)
    }
}

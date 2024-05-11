//
//  PieChartUIView.swift
//  MeRecipe
//
//  Created by Meng Siau on 11/5/2024.
//

import SwiftUI
import Charts

struct PieChartUIView: View {

    var body: some View {
        NavigationStack {
            VStack {
                Chart {
                    ForEach(TestData.data) { stream in
                        SectorMark(angle: .value("stream", stream.value),
                                   innerRadius: .ratio(0.618),
                                   angularInset: 2)
                            .foregroundStyle(by: .value("name", stream.name))
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
            .navigationTitle("title")
        }
    }
}

struct data: Identifiable {
    let id = UUID()
    let name: String
    let value: Int
}

struct TestData {
    static var data: [data] = [
        .init(name: "test1", value: 10),
        .init(name: "test2", value: 15),
        .init(name: "test3", value: 20),
    ]
}

#Preview {
    PieChartUIView()
}

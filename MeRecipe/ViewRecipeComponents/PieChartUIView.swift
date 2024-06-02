//
//  PieChartUIView.swift
//  MeRecipe
//
//  Created by Meng Siau on 11/5/2024.
//

import SwiftUI
import Charts

struct PieChartUIView: View {
    
    var chartData: [NutritionDataStructure] = []

    var body: some View {
        VStack {
            Chart {
                ForEach(chartData) { stream in
                    SectorMark(angle: .value("stream", stream.value),
                               innerRadius: .ratio(0.618),
                               angularInset: 2)
                        .foregroundStyle(by: .value("name", stream.name))
                        .cornerRadius(12)
                }
            }
            .chartLegend()
            .frame(width: 225, height: 225)
        }
    }
}

struct NutritionDataStructure: Identifiable {
    let id = UUID()
    let name: String
    let value: Int
}

// Debugging purposes //
struct TestData {
    static var data: [NutritionDataStructure] = [
        .init(name: "Protein", value: 10),
        .init(name: "Carbohydrates", value: 15),
        .init(name: "Fats", value: 20),
    ]
}

#Preview {
    PieChartUIView()
}

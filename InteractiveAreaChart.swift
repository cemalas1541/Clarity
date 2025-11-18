import SwiftUI
import Charts

struct InteractiveAreaChart: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let data: [ChartDataPoint]
    @Binding var selectedLabel: String?
    
    private var selectedDataPoint: ChartDataPoint? {
        if let selectedLabel = selectedLabel {
            return data.first(where: { $0.label == selectedLabel })
        }
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading) {
                Text(selectedDataPoint?.label ?? NSLocalizedString("general_total", comment: ""))
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.primaryTextColor)
                    .animation(.none, value: selectedDataPoint)
                
                HStack(spacing: 4) {
                    Text("\(selectedDataPoint?.totalMinutes ?? data.reduce(0) { $0 + $1.totalMinutes })")
                        .font(.title.bold())
                        .foregroundColor(themeManager.currentTheme.accentColor)
                        .contentTransition(.numericText())
                    
                    Text(NSLocalizedString("minutes_short", comment: ""))
                        .font(.title.bold())
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .opacity(selectedLabel == nil ? 0.5 : 1.0)
            .animation(.easeInOut, value: selectedDataPoint)
            
            Chart {
                ForEach(data) { point in
                    AreaMark(
                        x: .value(Text(NSLocalizedString("time_axis_label", comment: "")), point.label),
                        y: .value(Text(NSLocalizedString("minutes_axis_label", comment: "")), point.totalMinutes)
                    )
                    .foregroundStyle(themeManager.currentTheme.accentColor.gradient.opacity(0.3))
                    
                    LineMark(
                        x: .value(Text(NSLocalizedString("time_axis_label", comment: "")), point.label),
                        y: .value(Text(NSLocalizedString("minutes_axis_label", comment: "")), point.totalMinutes)
                    )
                    .foregroundStyle(themeManager.currentTheme.accentColor)
                    .symbol(.circle)
                    .opacity(selectedLabel == nil || selectedLabel == point.label ? 1.0 : 0.3)
                }
            }
            .frame(height: 250)
            .chartXSelection(value: $selectedLabel)
            .animation(.easeInOut, value: selectedLabel)
        }
        .padding()
        .liquidGlassBackground(opacity: 0.25)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(themeManager.currentTheme.accentColor.opacity(0.2), lineWidth: 1)
        )
    }
}

import SwiftUI

struct SettingsPanel: View {
    @ObservedObject var viewModel: FilePreviewViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("阅读设置")
                .font(.headline)
            
            // 字体设置
            VStack(alignment: .leading, spacing: 12) {
                Text("字体")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("字体", selection: Binding(
                    get: { viewModel.currentFont.name },
                    set: { viewModel.updateFont($0) }
                )) {
                    ForEach(FontSettings.availableFonts) { font in
                        HStack {
                            Text(font.name)
                                .font(.custom(font.name, size: 14))
                            Text(font.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(font.name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                // 字号调节
                HStack {
                    Text("字号")
                    Slider(
                        value: Binding(
                            get: { viewModel.settings.fontSize },
                            set: { viewModel.updateFontSize($0) }
                        ),
                        in: 12...32,
                        step: 1
                    ) {
                        Text("字号")
                    } minimumValueLabel: {
                        Text("12")
                    } maximumValueLabel: {
                        Text("32")
                    }
                }
                
                // 行间距调节
                HStack {
                    Text("行间距")
                    Slider(
                        value: Binding(
                            get: { viewModel.settings.lineSpacing },
                            set: { viewModel.updateLineSpacing($0) }
                        ),
                        in: 4...20,
                        step: 1
                    ) {
                        Text("行间距")
                    } minimumValueLabel: {
                        Text("4")
                    } maximumValueLabel: {
                        Text("20")
                    }
                }
            }
            
            Divider()
            
            // 主题设置
            VStack(alignment: .leading, spacing: 12) {
                Text("主题")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(ThemeSettings.availableThemes) { theme in
                    Button(action: { viewModel.updateTheme(theme.name) }) {
                        HStack {
                            Circle()
                                .fill(theme.backgroundColor)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.gray, lineWidth: 0.5)
                                )
                            
                            Text(theme.name)
                            
                            Spacer()
                            
                            if viewModel.currentTheme.name == theme.name {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Divider()
            
            // 底部按钮
            HStack {
                Button("重置") {
                    viewModel.resetSettings()
                }
                
                Spacer()
                
                Button("取消") {
                    viewModel.cancelSettings()
                }
                
                Button("确定") {
                    viewModel.saveSettings()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 300)
    }
} 
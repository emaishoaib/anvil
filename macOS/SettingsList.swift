import LauncherKit
import RulesKit
import SwiftUI

/// The rows of settings mode: with nothing typed, the page being looked at under its breadcrumb, and otherwise the settings that match the query, under a header per tool and a subheader per subgroup. A section's rows are indented one step under its header, and a subgroup's rows one step under its subheader. Only the rows on screen are built.
struct SettingsList: View {
    private static let rowHeight: CGFloat = 48
    private static let padding: CGFloat = 8
    private static let listHeight: CGFloat = 380
    private static let indentStep: CGFloat = 14
    static let height = listHeight + padding * 2

    let model: SettingsBarModel
    let open: (Setting) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(model.sections) { section in
                        SectionHeader(title: section.title)
                        ForEach(section.subgroups) { subgroup in
                            if let name = subgroup.name {
                                SubgroupHeader(title: name)
                                    .padding(.leading, Self.indentStep)
                            }
                            rows(of: subgroup)
                        }
                    }
                }
                .padding(Self.padding)
            }
            .frame(height: Self.height)
            .overlay { if model.sections.isEmpty { NoResults() } }
            .onChange(of: model.selected) {
                if let id = model.selectedSetting?.id { proxy.scrollTo(id) }
            }
        }
    }

    private func rows(of subgroup: SettingsBarModel.Subgroup) -> some View {
        ForEach(subgroup.settings) { setting in
            SettingRowView(
                setting: setting,
                isSelected: model.isSelected(setting),
                isRecording: model.isRecording(setting),
                adjustedValue: model.adjustedValue(of: setting),
                drag: { model.drag(setting, to: $0) },
                finishDragging: model.finishAdjusting
            )
            .frame(minHeight: Self.rowHeight)
            .padding(.leading, subgroup.name == nil ? Self.indentStep : Self.indentStep * 2)
            .id(setting.id)
            .onTapGesture { open(setting) }
        }
    }
}

private struct SubgroupHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.tertiary)
            .padding(.leading, 8)
            .frame(height: 24, alignment: .center)
    }
}

private struct SettingRowView: View {
    private static let disabledOpacity = 0.4

    let setting: Setting
    let isSelected: Bool
    let isRecording: Bool
    let adjustedValue: Double?
    let drag: @MainActor (Double) -> Void
    let finishDragging: @MainActor () -> Void

    var body: some View {
        HStack(spacing: 10) {
            SettingTitle(subtitle: setting.subtitle, warning: setting.warning) {
                if case .rule(let rule) = setting.row {
                    RuleLine(rule: rule)
                } else {
                    Text(setting.entry.title)
                }
            }
            Spacer()
            switch setting.row {
            case .toggle(let isOn, _):
                SwitchControl(isOn: isOn)
            case .choice(let selected, let options, _):
                ChosenOption(title: options[selected])
            case .number(let number):
                NumberControl(number: number, adjustedValue: adjustedValue, drag: drag, finishDragging: finishDragging)
                    .disabled(setting.isDisabled)
            case .shortcut(let combo, _, _):
                ShortcutControl(combo: combo, isRecording: isRecording)
            case .info(let value):
                if let value {
                    Text(value)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            case .page:
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
            case .action, .rule:
                EmptyView()
            }
        }
        .opacity(setting.isDisabled ? Self.disabledOpacity : 1)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxHeight: .infinity)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: SearchStyle.cornerRadius).fill(.primary.opacity(SearchStyle.selectionOpacity)) }
        }
        .contentShape(.rect)
    }
}

private struct SettingTitle<Title: View>: View {
    let subtitle: String?
    let warning: String?
    @ViewBuilder let title: Title

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            title
                .foregroundStyle(Color(nsColor: .textColor))
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            if let warning {
                Label(warning, systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct RuleLine: View {
    let rule: Rule

    var body: some View {
        HStack(spacing: 6) {
            RuleTriggerLabel(trigger: rule.trigger)
            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)
            RuleActionLabel(action: rule.action)
        }
    }
}

private struct SwitchControl: View {
    let isOn: Bool

    var body: some View {
        Toggle("", isOn: .constant(isOn))
            .toggleStyle(.switch)
            .labelsHidden()
            .controlSize(.small)
            .allowsHitTesting(false)
    }
}

private struct ChosenOption: View {
    let title: String

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .lineLimit(1)
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(.secondary)
    }
}

private struct ShortcutControl: View {
    let combo: KeyCombo?
    let isRecording: Bool

    var body: some View {
        if isRecording {
            Text("Type a shortcut…")
                .foregroundStyle(.tint)
        } else if let combo {
            KeyCaps(combo: combo)
        } else {
            Text("Record Shortcut")
                .foregroundStyle(.secondary)
        }
    }
}

/// A slider and the value it shows. While the row is being adjusted, from the keyboard or by dragging, the value is shown in the accent colour.
private struct NumberControl: View {
    private static let sliderWidth: CGFloat = 180
    private static let valueWidth: CGFloat = 96

    let number: SettingNumber
    let adjustedValue: Double?
    let drag: @MainActor (Double) -> Void
    let finishDragging: @MainActor () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Slider(value: Binding(get: { adjustedValue ?? number.value }, set: drag), in: number.range, step: number.step, onEditingChanged: { isEditing in
                if !isEditing { finishDragging() }
            })
            .controlSize(.small)
            .frame(width: Self.sliderWidth)
            Text(number.label(adjustedValue ?? number.value))
                .monospacedDigit()
                .foregroundStyle(adjustedValue == nil ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tint))
                .frame(width: Self.valueWidth, alignment: .trailing)
        }
    }
}

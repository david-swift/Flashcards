//
//  KeywordsRow.swift
//  Flashcards
//

import Adwaita

struct KeywordsRow: View {

    @Binding var keywords: [String]
    @State private var expanded = false
    @State private var focus = Signal()
    var title = "Keywords"
    var subtitle = "Keywords simplify the search for sets"
    var element = "Keyword"

    var view: Body {
        ExpanderRow()
            .title(title)
            .subtitle(subtitle)
            .suffix {
                VStack {
                    Button(icon: .default(icon: .listAdd)) {
                        keywords.append("")
                        expanded = true
                        focus.signal()
                    }
                    .style("flat")
                    .tooltip("Add \(element)")
                }
                .valign(.center)
            }
            .rows {
                List(.init(keywords.indices), selection: nil) { index in
                    let keyword = keywords[safe: index] ?? ""
                    EntryRow(element, text: .init {
                        keyword
                    } set: { newValue in
                        keywords[safe: index] = newValue
                    })
                    .suffix {
                        VStack {
                            Button(icon: .default(icon: .userTrash)) {
                                keywords = keywords.filter { $0 != keyword }
                            }
                            .style("flat")
                            .tooltip("Remove \(element)")
                        }
                        .valign(.center)
                    }
                    .entryActivated {
                        keywords.append("")
                        focus.signal()
                    }
                    .focus(index == keywords.count - 1 ? focus : .init())
                }
                .style("boxed-list")
                .padding()
            }
            .enableExpansion(.constant(!keywords.isEmpty))
            .expanded($expanded)
    }

}

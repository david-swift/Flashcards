//
//  ContentView.swift
//  Memorize
//

import Adwaita
import CAdw
import Foundation

struct ContentView: WindowView {

    @Binding var sets: [FlashcardsSet]
    @State("selected-set")
    private var selectedSet = ""
    @State private var flashcardsView: NavigationStack<FlashcardsView> = .init()
    @State private var search: Search = .hidden(query: "")
    @State private var editSearch: Search = .hidden(query: "")
    @State private var searchFocused = false
    @State private var editMode = false
    @State("width")
    private var width = 700
    @State("height")
    private var height = 550
    @State("maximized")
    private var maximized = false
    @State private var sidebarVisible = false
    var app: GTUIApp
    var window: GTUIApplicationWindow
    var modifySet: (FlashcardsSet) -> Void

    var smallWindow: Bool { width < 600 }

    var view: Body {
        NavigationView($flashcardsView, Loc.overview) { view in
            Bin()
                .child {
                    switch view {
                    case let .study(set):
                        ViewStack(element: set) { _ in
                            StudyView(set: binding(id: set))
                        }
                    case let .test(set):
                        TestView(set: binding(id: set))
                    }
                }
                .topToolbar {
                    HeaderBar.empty()
                }
        } initialView: {
            OverlaySplitView(
                visible: .init {
                    (smallWindow && sidebarVisible) || (!smallWindow && !sets.isEmpty)
                } set: { newValue in
                    sidebarVisible = newValue
                }
            ) {
                sidebar
            } content: {
                content
            }
            .collapsed(smallWindow)
        }
    }

    var sidebar: View {
        ScrollView {
            List(
                sets.sortScore(search.effectiveQuery),
                selection: .init {
                    selectedSet
                } set: { newValue in
                    selectedSet = newValue
                    sidebarVisible = false
                    editSearch = .hidden(query: "")
                }
            ) { set in
                Text(set.name)
                    .ellipsize()
                    .padding()
                    .halign(.start)
            }
            .style("navigation-sidebar")
        }
        .hexpand()
        .topToolbar(visible: search.visible) {
            SearchEntry()
                .placeholderText(Loc.searchSets)
                .text($search.query)
                .focused(.constant(true))
                .padding(5, .horizontal.add(.bottom))
        }
        .topToolbar {
            ToolbarView(
                sets: $sets,
                selectedSet: $selectedSet,
                search: $search,
                editSearch: $editSearch,
                searchFocused: $searchFocused,
                editMode: $editMode,
                app: app,
                window: window,
                addSet: addSet
            )
        }
    }

    @ViewBuilder var content: Body {
        if let index = sets.firstIndex(where: { $0.id == selectedSet }), let set = sets[safe: index] {
            let binding = Binding<FlashcardsSet> { sets[safe: index] ?? .init() } set: { sets[safe: index] = $0 }
            SetOverview(
                set: binding,
                editMode: $editMode,
                editSearch: $editSearch,
                searchFocused: $searchFocused,
                flashcardsView: $flashcardsView,
                sidebarVisible: $sidebarVisible,
                smallWindow: smallWindow,
                modifySet: modifySet
            ) {
                sets = sets.filter { $0.id != set.id }
            }
        } else {
            VStack {
                if !sets.isEmpty {
                    StatusPage(
                        Loc.noSelection,
                        icon: .custom(name: "io.github.david_swift.Flashcards.set-symbolic"),
                        description: Loc.noSelectionDescription
                    )
                    .centerMinSize()
                } else {
                    StatusPage(
                        Loc.noSets,
                        icon: .custom(name: "io.github.david_swift.Flashcards.set-symbolic"),
                        description: Loc.noSetsDescription
                    ) {
                        Button(Loc.createSet) {
                            addSet()
                        }
                        .style("pill")
                        .style("suggested-action")
                        .horizontalCenter()
                    }
                    .centerMinSize()
                }
            }
            .topToolbar {
                HeaderBar.start {
                    if smallWindow {
                        Button(icon: .default(icon: .sidebarShow)) {
                            sidebarVisible.toggle()
                        }
                        .tooltip(Loc.toggleSidebar)
                    }
                }
            }
        }
    }

    func window(_ window: Window) -> Window {
        window
            .size(width: $width, height: $height)
            .maximized($maximized)
    }

    func addSet() {
        let newSet = FlashcardsSet()
        sets.insert(newSet, at: 0)
        selectedSet = newSet.id
        editMode = true
    }

    func binding(id: String) -> Binding<FlashcardsSet> {
        .init {
            sets.first { $0.id == id } ?? .init()
        } set: { newValue in
            sets[safe: sets.firstIndex { $0.id == id }] = newValue
        }
    }

}

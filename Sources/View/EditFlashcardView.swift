//
//  EditFlashcardView.swift
//  Flashcards
//

import Adwaita

struct EditFlashcardView: View {

    @Binding var flashcard: Flashcard
    @State private var editTags = false
    @State private var focusBack = Signal()
    var index: Int
    var tags: [String]
    var focusedFront: String?
    var focusNext: () -> Void
    var delete: () -> Void

    var view: Body {
        FormSection("Flashcard \(index + 1)") {
            Form {
                EntryRow("Front", text: $flashcard.front)
                    .entryActivated {
                        focusBack.signal()
                    }
                    .focused(.constant(focusedFront == flashcard.id))
                EntryRow("Back", text: $flashcard.back)
                    .entryActivated {
                        focusNext()
                    }
                    .focus(focusBack)
            }
        }
        .suffix {
            HStack {
                TagsButton(selectedTags: $flashcard.tags.nonOptional, editTags: $editTags, tags: tags)
                Button(icon: .default(icon: .userTrash)) {
                    delete()
                }
                .style("flat")
                .tooltip("Delete Flashcard")
            }
        }
        .padding()
    }

}

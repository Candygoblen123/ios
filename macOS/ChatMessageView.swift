//
//  ChatView.swift
//  macOS
//
//  Created by Andrew Glaze on 2/5/21.
//

import SwiftUI

struct ChatMessageView: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("Message")
                .font(.title)
            HStack {
                Text("Author")
                    .lineLimit(1)
                Spacer()
                Text("Timestamp")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
        }.padding()
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatMessageView()
    }
}

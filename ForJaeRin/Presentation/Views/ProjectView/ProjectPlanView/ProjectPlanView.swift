//
//  ProjectPlanView.swift
//  ForJaeRin
//
//  Created by Yun Dongbeom on 2023/07/14.
//

import SwiftUI

struct ProjectPlanView: View {
    @State private var leftPaneWidth: CGFloat = 200
    @EnvironmentObject var projectFileManager: ProjectFileManager
    @State private var isViewReady = false

    var body: some View {
        VStack(spacing: 0) {
            if isViewReady {
                PresentationPageList(
                    pdfDocumentPages: projectFileManager.pdfDocument!.PDFPages
                )
                .background(Color.detailLayoutBackground)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isViewReady = true
        }
    }
}

struct ProjectPlanView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectPlanView()
    }
}

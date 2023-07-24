//
//  ImportPdfView.swift
//  ForJaeRin
//
//  Created by Yun Dongbeom on 2023/07/12.
//

import SwiftUI

/**
 1. 창에서 기본 상단 x(닫기)버튼을 누를 시, 초기 화면으로 되돌아감
 2. 파일 추가하기 버튼 누르기 -> PDF 파일 가져오기 Finder Open
 3. 프로젝트 생성 - 세부 내용 작성(발표제목 / 발표 목적 / 발표 대상 / 발표 예정 소요시간)
 4. 스크립트 입력 기능 - 각 PDF 페이지 별 키워드 및 스크립트 작성
 5. 발표자료 그룹화 기능 - PDF 그룹화하기
 
 각 스텝별로 하위 뷰를 생성하여 작업하면 좋을 것 같습니다.
 
 */
// MARK: 새 프로젝트를 생성하기 위한 시트뷰
struct ImportPDFView: View {
    @EnvironmentObject var projectFileManager: ProjectFileManager
    @EnvironmentObject var myData: MyData
    @Binding var isSheetActive: Bool
    @State var nextAvailable = false
    @Binding var step: Int {
        didSet {
            if step > 4 {
                sendMyData()
                isSheetActive = false
            }
        }
    }
    
    let mentions: [String] = ["PDF 가져오기", "PDF 가져오기", "발표 정보 입력하기", "스크립트 입력하기", "그룹 설정하기", ""]
    
    var body: some View {
        VStack {
            // header
            HStack {
                HStack {
                    Text(mentions[step])
                        .font(.system(size: 24))
                    Text("\(step)/4")
                        .font(.system(size: 15))
                        .opacity(0.3)
                        .padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 0))
                }
                .padding(EdgeInsets(top: 48, leading: 40, bottom: 0, trailing: 0))
                
                Spacer()
                
                Button {
                    print("닫기")
                    isSheetActive = false
                } label: {
                    Image(systemName: "xmark")
                        // .frame(width: 20, height: 20)
                }
                .padding(EdgeInsets(top: 46, leading: 0, bottom: 0, trailing: 40))
            }
            .frame(width: 868, height: 77)
            // body
            VStack {
                
                if step == 1 {
                    Spacer()
                    FileImporterButtonView(step: $step)
                        .environmentObject(myData)
                        .buttonStyle(AppButtonStyle(backgroundColor: Color(hex: "8B6DFF")))
                    Spacer()
                } else if step == 2 {
                    Spacer()
                    InputPresentationInfoView()
                        .environmentObject(myData)
                    Spacer()
                } else if step == 3 {
                    Spacer()
                    InputScriptView()
                        .environmentObject(myData)
                    Spacer()
                } else if step == 4 {
                    SettingGroupView(
                        groupIndex: Array(repeating: -1, count: myData.images.count), nextAvailable: $nextAvailable
                    ).environmentObject(myData)
                } else {
                    // JSON 파일 생성 후 저장 및 PDF 파일 복사본 같이 저장
                    
                    //
                }
                
            }
            HStack {
                Button {
                    print("prev")
                    if step > 1 {
                        step -= 1
                    }
                } label: {
                    Text("이전")
                }
                .buttonStyle(previousButtonFuction() ?
                             AppButtonStyle(backgroundColor : Color(hex: "2F2F2F").opacity(0.25), width: 92)
                                : AppButtonStyle(width: 92))
                .padding(EdgeInsets(top: 24, leading: 40, bottom: 29, trailing: 0))
                .disabled(previousButtonFuction())
                
                Spacer()
                
                Button {
                    print("next")
                    step += 1
                } label: {
                    Text("다음")
                }

                .buttonStyle(nextButtonFuction() ?
                             AppButtonStyle(backgroundColor: Color(hex: "2F2F2F").opacity(0.25), width: 92)
                                : AppButtonStyle(width: 92))
                .padding(EdgeInsets(top: 24, leading: 0, bottom: 29, trailing: 40))
                .disabled(nextButtonFuction())

            }
            .frame(width: 868, height: 99)
            .foregroundColor(Color(hex: "F6F5FA"))
            .background(Color(hex: "F6F5FA"))
            // footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    func previousButtonFuction () -> Bool {
        if step == 1 {
            return true
        }
        return false
    }
    
    func nextButtonFuction () -> Bool {
        if step == 1 {
            return true
        }
        
        if step == 2 {
            if myData.title == "" || myData.purpose == "" || myData.target == "" || myData.time == "" {
                return true
            }
        }
        return false
    }
    
    func sendMyData() {
        
        // MyData -> ProjectFileManager로 데이터 전달 시작!
        var stringTime = myData.time
        stringTime.removeLast()
        var intTime = Int(stringTime)
        var projectMetaData = ProjectMetadata(
            projectName: myData.title,
            projectGoal: myData.purpose,
            presentationTime: intTime!,
            creatAt: Date()
        )
        
        var pdfPages: [PDFPage] = []
        var pdfGroups: [PDFGroup] = []
        
        for index in 0..<myData.keywords.count {
            pdfPages.append(PDFPage(keywords: myData.keywords[index], script: myData.script[index]))
        }
        
        for index in 0..<myData.groupData.count {
            pdfGroups.append(
                PDFGroup(
                    name: myData.groupData[index][0],
                    range: PDFGroupRange(start: Int(myData.groupData[index][3])!,
                                         end: Int(myData.groupData[index][4])!),
                    setTime: Int(myData.groupData[index][1])! * 60 + Int(myData.groupData[index][2])!
                )
            )
        }
        
        var pdfDocumentManager = PDFDocumentManager(
            url: myData.url,
            PDFPages: pdfPages,
            PDFGroups: pdfGroups
        )
        
        projectFileManager.projectURL = myData.url
        projectFileManager.projectMetadata = projectMetaData
        projectFileManager.pdfDocument = pdfDocumentManager
        
        // MyData -> ProjectFileManager로 데이터 전달 완료!
        
        projectFileManager.exportFile()
        
        //
        
        // MyData -> ProjectFileManager로 데이터 전달
        // ProjectFileManager를 JSON으로 변환해서 저장
        // PDF파일도 복사해서 같은 폴더 아래에 넣는다.
        
        // 해당 경로에 가서 프로젝트 이름으로 폴더를 만든다. -> 중복 이름이 있으면 실패
        // // 폴더 만들면 해당 폴더 밑에 JSON 파일을 넣는다 + PDF 복사본도 넣는다
        // // // 해당 폴더 경로를 최근 프로젝트 이력에 넣는다.
        
    }
}

struct ImportPDFView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isSheetActive = false
        @State var step = 0
        ImportPDFView(isSheetActive: $isSheetActive, step: $step)
    }
}

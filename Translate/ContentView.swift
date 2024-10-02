//
//  ContentView.swift
//  Translate
//
//  Created by Yandel Gil on 10/1/24.
//

import SwiftUI
@preconcurrency import WebKit
import UniformTypeIdentifiers
import ServiceManagement
import AVFoundation
import Speech

struct ContentView: View {
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false

    var body: some View {
        VStack {
            WebView(url: URL(string: "https://translate.google.com/")!)
                .frame(width: 400, height: 500)
            // https://translate.google.com/
            HStack {
                Button(action: {
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshWebView"), object: nil)
                }) {
                    Image(systemName: "arrow.clockwise")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .cornerRadius(5)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 5)

                Button(action: {
                    NSApp.terminate(nil)
                }) {
                    Text("Salir")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .cornerRadius(5)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 5)

                Button(action: {
                    clearCookiesAndRefresh()
                }) {
                    Text("Borrar Cookies")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .cornerRadius(5)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 5)

                Toggle("Abrir al inicio", isOn: $launchAtLogin)
                    .padding(.horizontal, 10)
                    .onChange(of: launchAtLogin) { newValue in
                        let appService = SMAppService.mainApp
                        do {
                            if newValue {
                                try appService.register()
                            } else {
                                try appService.unregister()
                            }
                        } catch {
                            print("Error al cambiar el estado de inicio al iniciar: \(error)")
                        }
                    }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            requestPermissions()
        }
    }

    func clearCookiesAndRefresh() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: [WKWebsiteDataTypeCookies]) { records in
            dataStore.removeData(ofTypes: [WKWebsiteDataTypeCookies], for: records) {
                print("Cookies borradas")
                NotificationCenter.default.post(name: NSNotification.Name("RefreshWebView"), object: nil)
            }
        }
    }

    func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if granted {
                print("Permiso para usar el micrófono concedido")
            } else {
                print("Permiso para usar el micrófono denegado")
            }
        }

        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Permiso para el reconocimiento de voz concedido")
            case .denied, .restricted, .notDetermined:
                print("Permiso para el reconocimiento de voz denegado")
            @unknown default:
                print("Estado de autorización desconocido")
            }
        }
    }
}

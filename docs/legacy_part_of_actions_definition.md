
```
#          find artifacts/javafx-app-linux -name "*.tar.gz" -exec cp {} release-assets/ \;
#          find artifacts/javafx-app-windows -name "*.zip" -exec cp {} release-assets/ \;
#          find artifacts/javafx-app-macos -name "*.tar.gz" -exec cp {} release-assets/ \;
#          find artifacts/javafx-app-android -name "*.apk" -exec cp {} release-assets/ \;
#          echo "Release assets:"
#          ls -la release-assets/

#      - name: Generate release notes
#        id: release_notes
#        run: |
#          cat > release_notes.md << 'EOF'
#          ## JavaFX Cross-Platform Application Release ${{ steps.tag.outputs.tag }}
#
#          ### 🎉 What's New
#          - Cross-platform JavaFX application with native compilation
#          - Support for Windows, macOS, Linux, and Android platforms
#          - Optimized native executables using GraalVM
#
#          ### 📦 Downloads
#          Choose the appropriate package for your platform:
#
#          - **🐧 Linux (x64)**: javafx-app-linux-x64.tar.gz
#            - Extract and run ./start.sh or ./javafx-cross-platform-starter
#
#          - **🪟 Windows (x64)**: javafx-app-windows-x64.zip
#            - Extract and run start.bat or javafx-cross-platform-starter.exe
#
#          - **🍎 macOS**: javafx-app-macos.tar.gz
#            - Extract and run ./start.sh or ./javafx-cross-platform-starter
#
#          - **🤖 Android**: javafx-app-android.apk
#            - Install on Android device (requires enabling "Unknown sources")
#
#          ### 🚀 Installation Instructions
#
#          #### Desktop Platforms (Linux/Windows/macOS)
#          1. Download the appropriate archive for your platform
#          2. Extract the archive to a directory of your choice
#          3. Run the startup script or executable directly
#          4. Enjoy the application!
#
#          #### Android
#          1. Download the APK file
#          2. Enable "Install from unknown sources" in your Android settings
#          3. Install the APK file
#          4. Launch the app from your app drawer
#
#          ### 🔧 Requirements
#          - **Desktop**: No additional requirements (self-contained executables)
#          - **Android**: Android 7.0 (API level 24) or higher
#
#          ### 🐛 Known Issues
#          - First launch may take a few seconds due to native compilation optimizations
#          - On macOS, you may need to allow the app in System Preferences > Security & Privacy
#          EOF

#      - name: Create GitHub Release
#        uses: ncipollo/release-action@v1
#        with:
#          tag: ${{ steps.tag.outputs.tag }}
#          name: JavaFX Cross-Platform App ${{ steps.tag.outputs.tag }}
#          bodyFile: release_notes.md
#          draft: false
#          prerelease: ${{ contains(steps.tag.outputs.tag, '-') || contains(steps.tag.outputs.tag, 'alpha') || contains(steps.tag.outputs.tag, 'beta') || contains(steps.tag.outputs.tag, 'rc') }}
#          artifacts: release-assets/*
#          token: ${{ secrets.GITHUB_TOKEN }}
#          makeLatest: true
```
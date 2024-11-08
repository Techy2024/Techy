# Techy

## assets
    - terms and condition (使用者協議的部分)

## images
    - 第三方登入 icon

## Pages
    - auth_page.dart 
        
    - calendar_page.dart (還有一點小 bug 不過小問題)
        行事曆頁面，目前有的功能為
        1. 讀取 DB 中 Tag 為 1 的行程並加入到行事曆 UI 中
        2. 在頁面中直接新增行程 (同步更新至 DB)
        3. 刪除行程(滑動刪除還有 bug) (同步更新至 DB)

        需新增
        1. 行事曆上行程編輯
        2. 跨天行程
    
    - home_page.dart
        只是拿來測試用的主頁

    - login_page.dart
        login 頁面
    
    - login_or_register_page.dart && register_page.dart
        用不到但先別刪，還沒維護好

    - test_page.dart
        目前拿來放標 DB tag 的功能
        之後看是要寫成 backward service 還是什麼在修改他的程式碼

## services
    - auth_service.dart
        登入用 service

    - location_service.dart
        監測使用者位置的背景 service

    - ollama_service.dart
        哈哈失敗版本可以不要理他

## firebase_option
    連接 firebase 的設定表，直接複製貼上應該可

## main.dart
    main.dart

## 其他
    - firebase.json
    連 firebase 必要的檔案

    - pubspec.lock
    不知道是啥

    - pubspec.yaml
    裡面套件基本上都是必要的，版本 latest 應該都可以用

    - 兩個亂碼檔名文件
    firebase 上 authentication 中 google 登入的授權碼(應該是叫這個)
    直接複製應該就可

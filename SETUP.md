# Firebase Setup Guide - Swift Package Manager

## 🚀 Modern Setup Using Swift Package Manager (SPM)

### Step 1: Add Firebase Package in Xcode

1. **Open your project** - Double-click `AI.xcodeproj` in Finder
2. **Add Package Dependency**
   - Go to **File → Add Package Dependencies...**
   - Or click your project in the navigator → Select **Package Dependencies** tab → Click **+**
3. **Enter Firebase URL**: `https://github.com/firebase/firebase-ios-sdk`
4. **Choose version**: Select **11.6.0** (or "Up to Next Major Version")
5. **Click Add Package**
6. **Select these products** (check the boxes):
   ```
   ✅ FirebaseAuth
   ✅ FirebaseCore
   ✅ FirebaseFirestore
   ✅ FirebaseVertexAI
   ```
7. **Click Add Package** again
8. Wait for Xcode to download (may take 1-2 minutes)

### Step 2: Download GoogleService-Info.plist

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. **Create a project** or select existing one
3. Click **Add app** → Select **iOS** icon
4. **Enter Bundle ID**:
   - Find yours in Xcode: Select project → General tab → Identity section
   - Usually something like `com.yourname.AI`
5. **Download** `GoogleService-Info.plist`
6. **Drag file into Xcode**:
   - Drag it next to `AIApp.swift` in the project navigator
   - ✅ Check "Copy items if needed"
   - ✅ Check your target (AI)
   - Click Finish

### Step 3: Enable Firebase Services in Console

Open [Firebase Console](https://console.firebase.google.com/) for your project:

#### A. Authentication (Required)
1. Go to **Build → Authentication**
2. Click **Get Started**
3. Click **Sign-in method** tab
4. Enable **Anonymous**
5. Click **Save**

#### B. Firestore Database (Required)
1. Go to **Build → Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select your **region** (choose closest to you)
5. Click **Enable**

#### C. Vertex AI for Firebase (Required for AI Quests)
1. Go to **Build → Vertex AI in Firebase**
   - Or search for "Vertex AI" in the left sidebar
2. Click **Get Started** or **Upgrade**
3. **Important**: You may need to upgrade to Blaze (pay-as-you-go) plan
   - Don't worry - it has a generous free tier
   - Gemini 1.5 Pro is free for limited requests
4. Enable the service

### Step 4: Build Your Project

1. **Clean build folder**: Press **Shift + Cmd + K**
2. **Build**: Press **Cmd + B**
3. **Run**: Press **Cmd + R**

If you see errors, go to Troubleshooting section below.

---

## 🎮 Test Your Setup

Once running:

1. **Cat should appear** and you can move with WASD/arrows
2. **Press Q** → Opens Quest Panel
3. **Click "Generate AI Quest"**
   - If quest appears → ✅ Everything works!
   - If error → Check troubleshooting below

---

## 🔧 Troubleshooting

### ❌ "Module 'FirebaseAuth' not found"
**Fix:**
1. Go to **File → Packages → Reset Package Caches**
2. **Product → Clean Build Folder** (Shift + Cmd + K)
3. Close Xcode
4. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```
5. Reopen project and build

### ❌ "GoogleService-Info.plist not found"
**Fix:**
1. Make sure file is in project navigator (left sidebar)
2. Click the file → Right panel → **Target Membership** → Check **AI**
3. File should be in same folder as `AIApp.swift`

### ❌ AI Quest Generation fails
**Possible causes:**

1. **Vertex AI not enabled**
   - Check Firebase Console → Vertex AI → Make sure it's enabled

2. **Billing not set up**
   - Vertex AI requires Blaze plan (pay-as-you-go)
   - Go to Firebase Console → Upgrade
   - Free tier is generous for testing

3. **Wrong model name**
   - Check `FirebaseService.swift` line 34
   - Should say: `gemini-1.5-pro`

4. **Network error**
   - Check your internet connection
   - Check Firebase console for any service outages

### ❌ Build succeeds but app crashes
**Fix:**
1. Check Console output for error message
2. Common issue: `FirebaseApp.configure()` not called
   - Should already be in `AIApp.swift` line 15
3. Check `GoogleService-Info.plist` is valid (open and verify it's XML, not HTML)

### ❌ "Cannot find 'FirebaseVertexAI' in scope"
**Fix:**
- Firebase Vertex AI might still be in preview
- Try using: `FirebaseVertexAI-Preview` when adding package
- Or update Firebase SDK to latest version (11.6.0+)

---

## 📋 Package Versions

Using these in your project:
- **Firebase iOS SDK**: 11.6.0 or later
- **Gemini Model**: 1.5 Pro (better quality than Flash)

---

## 🎯 What Each Service Does

| Service | Purpose |
|---------|---------|
| **FirebaseAuth** | Anonymous user login (no passwords needed) |
| **FirebaseCore** | Core Firebase functionality |
| **FirebaseFirestore** | Save/load game progress to cloud |
| **FirebaseVertexAI** | AI quest generation using Gemini |

---

## 💡 Pro Tips

1. **Development**: Use Firestore test mode (no authentication rules)
2. **Production**: Switch to production mode with proper security rules
3. **AI Costs**: Gemini 1.5 Pro is free for limited requests (~15 requests/min)
4. **Offline**: Game works offline, but saving/AI requires internet

---

## ✅ Verification Checklist

Before running:
- [ ] Firebase packages added via SPM
- [ ] `GoogleService-Info.plist` in project
- [ ] Authentication enabled (Anonymous)
- [ ] Firestore database created
- [ ] Vertex AI enabled
- [ ] Project builds without errors

After running:
- [ ] Cat appears and moves
- [ ] Stats panel shows (top-left)
- [ ] Quest panel opens (press Q)
- [ ] AI quest generates successfully

# Antigravity IDE CLI Launcher (`ant`)

Launch any project folder in **Google Antigravity IDE** instantly from **Command Prompt (CMD)** and **PowerShell (pwsh)** using simple commands like `ant .` (just like `code .` for VS Code).

---

## ⚡ Quick One-Line Install (ফ্রেশ ওএসে ১-লাইনেই ইনস্টল)

কোনো ফাইল ম্যানুয়ালি ডাউনলোড বা কনফিগার করতে হবে না! উইন্ডোজের যেকোনো টার্মিনালে নিচের এক লাইনের কমান্ডটি পেস্ট করে এন্টার দিন:

### In PowerShell / pwsh:
```powershell
irm https://raw.githubusercontent.com/Cyber-arghya/antigravity-launcher/main/install.ps1 | iex
```

### In Command Prompt (CMD):
```cmd
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Cyber-arghya/antigravity-launcher/main/install.ps1 | iex"
```

> **Note**: ইনস্টল সম্পন্ন হওয়ার পর বর্তমান সেশন থেকেই `ant .` কাজ করবে! নতুন CMD উইন্ডোর ক্ষেত্রে একবার CMD বন্ধ করে আবার ওপেন করতে হতে পারে।

---

## 🚀 ব্যবহারের নিয়ম (Usage)

### Command Prompt (CMD):
```cmd
:: বর্তমান ফোল্ডার ওপেন করতে (Current Folder)
ant .

:: নতুন উইন্ডোতে ওপেন করতে (New Window)
ant -n .

:: নির্দিষ্ট কোনো ফোল্ডার ওপেন করতে (Specific Folder)
ant "C:\path\to\your-project"
```

### PowerShell (pwsh):
```powershell
# বর্তমান ফোল্ডার ওপেন করতে
ant .

# নতুন উইন্ডোতে ওপেন করতে
ant -n .
ant -NewWindow .

# নির্দিষ্ট ফোল্ডার ওপেন করতে
ant "C:\path\to\your-project"
ant -NewWindow "D:\Projects\MyApp"
```

---

## 📁 Repository Contents

| ফাইল | বিবরণ |
|---|---|
| **[`install.ps1`](install.ps1)** | ওয়ান-লাইন রিমোট ইনস্টলার স্ক্রিপ্ট (One-line remote installer)। |
| **[`setup.bat`](setup.bat)** | অফলাইন / লোকাল ডাবল-ক্লিক অটো ইনস্টলার (One-click double-clickable batch setup)। |
| **[`ant.cmd`](ant.cmd)** | CMD এবং গ্লোবাল PATH-এর জন্য মেইন এক্সিকিউটেবল স্ক্রিপ্ট। |
| **[`ant.ps1`](ant.ps1)** | PowerShell নেটিভ ফাংশন `Open-Antigravity` ও `ant` অ্যালিয়াস। |

---

## 🛠️ ফিচার ও সুবিধা (Features)

1. **Auto-Discovery**: ফ্রেশ ওএসে `PATH` আপডেট না থাকলেও এটি `%LOCALAPPDATA%`, `%ProgramFiles%`, এবং `%ProgramFiles(x86)%`-এ Antigravity IDE-এর অবস্থান খুঁজে নিয়ে স্বয়ংক্রিয়ভাবে চালু করে।
2. **Dual-Shell Compatibility**: একই কমান্ড (`ant .`) CMD ও PowerShell উভয় স্থানেই সমভাবে কাজ করে।
3. **Zero Configuration**: এক ক্লিকে বা এক লাইনে সেটআপ হয়ে যায়।

---

## 👤 Author
- **GitHub**: [@Cyber-arghya](https://github.com/Cyber-arghya)
- **Email**: [work.arghya01@gmail.com](mailto:work.arghya01@gmail.com)

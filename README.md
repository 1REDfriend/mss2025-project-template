# Demo Project: Missing Semester 2025 (Live Server Stats)

This repository is a demo project for junior students. The goal is to build a system that automatically monitors and displays the resource usage of an **Ubuntu Server** on a public **GitHub Pages** website.

## 📝 Project Overview
This is a group project (4-5 members) that combines several key infrastructure concepts:

* **Virtualization:** You will use two VMs: an **Ubuntu Desktop** (as your client machine) and an **Ubuntu Server** (as your target machine).
* **Remote Connectivity:** Students will use the **Desktop VM** to **SSH** into the **Server VM**, where all work will be done.
* **Shell Scripting:** You will write a **BASH script** to collect system resource information (CPU usage, memory usage, storage, etc.) from the **Ubuntu Server**.
* **Git Automation (Branching):** Instead of pushing directly to `main`, your shell script will be responsible for committing changes and pushing them to **your own individual branch** (e.g., `member-1-stats`).
* **CI/CD & Automation:** TAs have provided a **GitHub Actions workflow** (`auto_merge.yaml`). Once all members have their scripts running, this workflow will automatically merge all individual branches into the `main` branch every 10 minutes.
* **GitHub Pages:** The repository is configured to host a static website. The `main` branch will update the live site with the combined data from all members.

## ⚙️ How It Works (The Workflow)

1.  **Fork & Clone:** The group forks this template repository.
2.  **Individual Work:** Each member works on their own dedicated **branch** (do not push to `main` directly).
3.  **The Script:** Your **BASH script** runs via `cron` on your server. It updates your specific HTML/Data file and pushes the changes to your **individual branch**.
4.  **The Merge:** The `auto_merge.yaml` workflow runs automatically every 10 minutes. It collects the updates from everyone's branches and merges them into `main`.
5.  **The Result:** **GitHub Pages** sees the update on `main` and publishes the new stats to the live website.

## 🏁 The Final Product
The **GitHub Pages** site will feature:

* A **Main Group Page** (`index.html`) that links to everyone's profiles.
* **Individual Pages** for each group member, displaying real-time system stats pulled from their respective **Ubuntu Servers**.
___
# โปรเจกต์สาธิต: Missing Semester 2025 (Live Server Stats)

Repository นี้เป็นโปรเจกต์สาธิตสำหรับนักศึกษาชั้นปีที่ 1 เป้าหมายคือการสร้างระบบที่ตรวจสอบและแสดงผลการใช้งาน Resource ของ **Ubuntu Server** บนเว็บไซต์สาธารณะผ่าน **GitHub Pages** แบบอัตโนมัติ

## 📝 ภาพรวมโปรเจกต์
นี่คือโปรเจกต์กลุ่ม (สมาชิก 7-8 คน) ที่รวมแนวคิดพื้นฐานด้าน Infrastructure ที่สำคัญเข้าด้วยกัน:

* **Virtualization:** คุณจะใช้ **VMs** 2 ตัว ได้แก่ **Ubuntu Desktop** (เครื่อง Client) และ **Ubuntu Server** (เครื่องเป้าหมาย)
* **Remote Connectivity:** นักศึกษาจะใช้ **Desktop VM** เพื่อ **SSH** เข้าไปยัง **Server VM** ซึ่งงานทั้งหมดจะทำที่นั่น
* **Shell Scripting:** คุณต้องเขียน **BASH script** เพื่อรวบรวมข้อมูลทรัพยากรระบบ (CPU usage, memory, storage ฯลฯ) จาก **Ubuntu Server**
* **Git Automation (Branching):** แทนที่จะ Push เข้า `main` โดยตรง สคริปต์ของคุณจะทำการ Commit และ Push การเปลี่ยนแปลงไปยัง **Branch ส่วนตัวของคุณ** (เช่น `member-1-stats`)
* **CI/CD & Automation:** พี่ TA ได้เตรียม **GitHub Actions workflow** (`auto_merge.yaml`) ไว้ให้ เมื่อสมาชิกทุกคนรันสคริปต์เสร็จแล้ว Workflow นี้จะทำการ Merge ทุก Branch เข้าสู่ `main` ให้โดยอัตโนมัติทุกๆ 10 นาที
* **GitHub Pages:** Repository นี้ถูกตั้งค่าให้โฮสต์ Static Website โดย Branch `main` จะอัปเดตหน้าเว็บจริงด้วยข้อมูลที่รวมมาจากสมาชิกทุกคน

## ⚙️ ขั้นตอนการทำงาน (The Workflow)

1.  **Fork & Clone:** กลุ่มทำการ Fork Template Repository นี้
2.  **Individual Work:** สมาชิกแต่ละคนทำงานใน **Branch** ของตัวเอง (ห้าม Push เข้า `main` โดยตรง)
3.  **The Script:** **BASH script** จะรันผ่าน `cron` บน Server ของคุณ เพื่ออัปเดตไฟล์และ Push ไปยัง **Branch ส่วนตัว**
4.  **The Merge:** ไฟล์ `auto_merge.yaml` จะทำงานอัตโนมัติทุก 10 นาที เพื่อรวบรวมอัปเดตจาก Branch ของทุกคนและ Merge เข้า `main`
5.  **The Result:** **GitHub Pages** ตรวจพบการอัปเดตบน `main` และแสดงผลสถิติใหม่บนหน้าเว็บ

## 🏁 ผลลัพธ์สุดท้าย
เว็บไซต์บน **GitHub Pages** จะประกอบด้วย:
* **หน้าหลักของกลุ่ม** (`index.html`) ที่มีลิงก์ไปยังโปรไฟล์ของทุกคน
* **หน้าส่วนตัว** ของสมาชิกแต่ละคน ที่แสดงสถิติ System Stats แบบ Real-time ที่ดึงมาจาก **Ubuntu Server** ของคนนั้นๆ
___
# Projet Démo : Missing Semester 2025 (Live Server Stats)

Ce **repository** est un projet de démonstration pour les étudiants juniors. L'objectif est de construire un système qui surveille et affiche automatiquement l'utilisation des ressources d'un **Ubuntu Server** sur un site web public via **GitHub Pages**.

## 📝 Aperçu du Projet
Il s'agit d'un projet de groupe (4-5 membres) combinant plusieurs concepts clés d'infrastructure :

* **Virtualization :** Vous utiliserez deux **VMs** : un **Ubuntu Desktop** (machine client) et un **Ubuntu Server** (machine cible).
* **Remote Connectivity :** Les étudiants utiliseront la **VM Desktop** pour se connecter via **SSH** à la **VM Server**, où tout le travail sera effectué.
* **Shell Scripting :** Vous écrirez un **BASH script** pour collecter les informations sur les ressources système (CPU, mémoire, stockage, etc.) de l'**Ubuntu Server**.
* **Git Automation (Branching) :** Au lieu de pousser directement vers `main`, votre script sera responsable de valider (commit) et de pousser les changements vers **votre propre branch individuel** (ex : `member-1-stats`).
* **CI/CD & Automation :** Les assistants (TAs) ont fourni un **GitHub Actions workflow** (`auto_merge.yaml`). Une fois que tous les scripts des membres sont opérationnels, ce workflow fusionnera (merge) automatiquement toutes les branches individuelles dans la branch `main` toutes les 10 minutes.
* **GitHub Pages :** Le repository est configuré pour héberger un site statique. La branch `main` mettra à jour le site en direct avec les données combinées.

## ⚙️ Fonctionnement (The Workflow)

1.  **Fork & Clone :** Le groupe fork ce template repository.
2.  **Individual Work :** Chaque membre travaille sur son propre **branch** dédié (ne pas pousser directement sur `main`).
3.  **The Script :** Votre **BASH script** s'exécute via `cron` sur votre serveur. Il met à jour vos fichiers et les pousse vers votre **branch individuel**.
4.  **The Merge :** Le workflow `auto_merge.yaml` s'exécute automatiquement toutes les 10 minutes. Il collecte les mises à jour de toutes les branches et les fusionne dans `main`.
5.  **The Result :** **GitHub Pages** détecte la mise à jour sur `main` et publie les nouvelles statistiques sur le site web.

## 🏁 Le Produit Final
Le site **GitHub Pages** comportera :
* Une **Page Principale de Groupe** (`index.html`) avec des liens vers les profils de chacun.
* Des **Pages Individuelles** pour chaque membre, affichant les stats système en temps réel tirées de leurs **Ubuntu Servers** respectifs.
___
# デモプロジェクト：Missing Semester 2025 (Live Server Stats)

この **Repository** は、後輩学生向けのデモプロジェクトです。目標は、**Ubuntu Server** のリソース使用状況を自動的に監視し、**GitHub Pages** 上の公開ウェブサイトに表示するシステムを構築することです。

## 📝 プロジェクト概要
これは、いくつかの重要なインフラ概念を組み合わせたグループプロジェクト（4〜5名）です：

* **Virtualization:** 2つの **VM** を使用します：**Ubuntu Desktop**（クライアントマシン）と **Ubuntu Server**（ターゲットマシン）。
* **Remote Connectivity:** 学生は **Desktop VM** を使用して **Server VM** に **SSH** 接続し、そこで全ての作業を行います。
* **Shell Scripting:** **Ubuntu Server** からシステムリソース情報（CPU使用率、メモリ、ストレージなど）を収集するための **BASH script** を作成します。
* **Git Automation (Branching):** 直接 `main` に Push するのではなく、スクリプトは変更をコミットし、**個人の Branch**（例：`member-1-stats`）に Push します。
* **CI/CD & Automation:** TA が **GitHub Actions workflow** (`auto_merge.yaml`) を用意しました。全員のスクリプトが稼働すると、この Workflow が10分ごとに全ての Branch を `main` に自動的に Merge します。
* **GitHub Pages:** この Repository は静的ウェブサイトをホストするように設定されています。`main` Branch は全員のデータを結合してサイトを更新します。

## ⚙️ 仕組み (The Workflow)

1.  **Fork & Clone:** グループはこのテンプレート Repository を Fork します。
2.  **Individual Work:** 各メンバーは専用の **Branch** で作業します（`main` に直接 Push しないでください）。
3.  **The Script:** **BASH script** はサーバー上の `cron` 経由で実行されます。ファイルを更新し、**個人の Branch** に Push します。
4.  **The Merge:** `auto_merge.yaml` ワークフローは10分ごとに自動実行されます。全員の Branch から更新を収集し、`main` に Merge します。
5.  **The Result:** **GitHub Pages** は `main` の更新を検知し、新しい統計情報をウェブサイトに公開します。

## 🏁 最終成果物
**GitHub Pages** サイトには以下が含まれます：
* 全員のプロフィールへのリンクがある **メイングループページ** (`index.html`)。
* 各メンバーの **Ubuntu Server** から取得したリアルタイムのシステム統計を表示する **個別ページ**。
<img width="472" height="410" alt="image" src="https://github.com/user-attachments/assets/eb280e77-f5d8-4916-bf37-827e8da7b5b5" />

# Guanguan — Savings App

A Flutter-based Android savings app. Built-in savings challenges with daily check-in, plus savings-plan recommendations based on income. Apple-minimal design with a macaron mint-lime palette.

- **Platform**: Android (Flutter, extensible to iOS)
- **Tech stack**: Flutter 3 · Dart · Riverpod · SQLite (sqflite) · fl_chart
- **Run**: `cd src/jar_jar && flutter pub get && flutter run`
- **Download signed release APK**: see [Releases](../../releases)
- **Status**: skeleton / work in progress
- **Note**: The README below is in Chinese.

---

# 罐罐 — 存钱 App

> 把每一块钱，存进梦想的罐子 🫙

## 项目概述

一款基于 Flutter 的 Android 存钱 App。内置多种存钱方法，用户可选择挑战并每日打卡；也可输入收入由 App 智能推荐存钱方案。设计风格为苹果极简风 + 马卡龙薄荷青柠配色。

- **平台**：Android（Flutter 跨平台，后续可扩展 iOS）
- **目标用户**：年轻人（学生党、职场新人）
- **核心功能**：存钱挑战打卡 + 智能存钱规划

## 技术栈

| 层 | 技术 |
|----|------|
| 框架 | Flutter 3.x |
| 语言 | Dart |
| 状态管理 | Riverpod |
| 本地存储 | SQLite (sqflite) + SharedPreferences |
| 通知 | flutter_local_notifications |
| 图表 | fl_chart |

## 快速开始

```bash
# 安装 Flutter SDK 后
cd src/罐罐
flutter pub get
flutter run
```

## 项目状态

- 创建日期：2026-07-18
- 当前阶段：骨架搭建中

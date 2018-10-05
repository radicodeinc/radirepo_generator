
# Radicode Daily Report Generator

日報作成ツールです。

## インストール

```
% gem install specific_install
% gem specific_install git@github.com:radicodeinc/radirepo_generator.git master
```

## gem更新

```
% gem specific_install git@github.com:radicodeinc/radirepo_generator.git master
```

## 使い方

以下のコマンドを実行すると、日報のテンプレートが`radicodeinc/daily_report`のissueにwipとして作成され、作成されたページが開く。
```
% radirepo activity
```

※ 一日に何度実行しても、1issueしか作成されず、github activityが更新される。

## 設定ファイル

CLIに慣れている人は、`radirepo activity`初回実行時に自動的にエディタが立ち上がるはず。
慣れてない人は、以下のコマンド実行してから`radirepo activity`
```
% export EDITOR=/usr/bin/vim
```

それでもダメなら下の情報を参考に自力設定する。

`~/.pit/default.yaml`
```
---↲
github.com:↲
  access_token: 123456789abcdefg....↲
radirepo_generator:↲
  username: 佐藤
  ignore_repositories: hogehoge/fugafuga
```


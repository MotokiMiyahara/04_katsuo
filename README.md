コード銀行：大漁！初がつお
====

使用例

`./categorize.rb data/katsuo1000.csv`

`./categorize.rb --config=sawara.txt data/katsuo1000.csv`

`./categorize.rb --config=all_maguro.txt data/katsuo1000.csv`

## 解答
[answer.txt](answer.txt) を参照してください。


## 問題文
###【問題】

CSVファイルに、魚の名前と大きさ（整数値、単位はcm）が書かれています。

このファイルを読み込み、“カツオ”の大きさを次のように分類してください。
    Sサイズ…50cm未満

    Mサイズ…50cm以上、75cm未満

    Lサイズ…75cm以上
さらに、分類ごとのカツオの数、大きさの平均値を計算してください。

小数点以下は、小数第3位を四捨五入し、小数第2位まで出力してください。


###【テストデータ】

[katsuo.zip]をダウンロード、展開すると、以下のファイルが含まれています。

`answer.txt`

解答用テキストファイルです。
`katsuo10.csv`

サンプルの入力データで、次のように書かれています。

    カツオ,86
    カツオ,79
    カツオ,36
    カツオ,61
    カツオ,69
    カツオ,69
    カツオ,37
    カツオ,76
    カツオ,37
    カツオ,73

この入力の場合は、

    S(3): 36.67cm
    M(4): 68.00cm
    L(3): 80.33cm


のように出力してください。

`katsuo1000.csv`
このファイルを入力データとしてください。


###【解答方法】
answer.txtに必要事項を記入し、テキストファイルのままアップロードしてください。

※answer.txt以外のファイルをzipに固めてアップロードした場合は評価対象外となります。

### 【注意】

・出力結果に誤りがある場合は最低評価になります。

・問題本文だけでなく「解答評価のポイント」「その他注意事項」をよくお読みください。

### 【出題URL】
[https://codeiq.jp/challenge_answer/130940](https://codeiq.jp/challenge_answer/130940)

## Author
[MotokiMiyahara](https://github.com/MotokiMiyahara/)



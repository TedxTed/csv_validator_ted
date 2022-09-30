# Quest: Simple CSV Validator

這是一個簡單的 csv 檔案檢查程式

其中只定義了 RSpec 的測試案例

請實作實際的程式內容，來通過這些 rspec test case

你僅需要實作 lib/ 路徑下的檔案，你可以任意修改裡面的程式碼或增加其他檔案

你不需要修改 spec/ 路徑下的檔案

最後讓 rspec 測試順利通過(或盡可能通過愈多測試 case)

## Setup Environment

預設使用 ruby 2.7.5

你也可以選擇其他 2.0 以上版本進行開發，只要能順利運作


```
bundle
bundle exec rspec
```

## 說明

### 情境

我們想要 import `CSV 檔案` 進入資料庫的某張 `資料表`

已知我們會有該張資料表的結構(schema)資訊[1]

然而，在實際 import 之前，我們想先對要匯入的 CSV 檔案做檢查，是否符合該張資料表的這些條件：

- CSV檔案中的資料(rows)不可以是空的
- CSV檔案中的每列資料(row)的 id 欄位值，彼此之間不可以重複
- 會檢查 schema 中被定義是 not null (null: false) - 不允許空值的欄位，在 CSV 檔案中對應的資料必須要有值，除非：
  - schema 中該欄位設有預設值 (default: ... )；或者
  - schema 中該欄位設有 auto increment (auto_increment: true)
- 會檢查 schema 中被定義格式是時間 (type: 'datetime')的欄位，在 CSV 檔案中對應的資料值，時間格式是否正確
- 會檢查 schema 中被定義為字串的「多語言」欄位[2]，在 CSV 檔案中對應的資料，是否超過該欄位的文字長度限制
  - 如果該欄位在 schema 中沒有特別指定 string 的長度限制，那預設限制為 255 字

**你的目標就是要實作出這個檢查 CSV 格式是否正確的 Validator 程式**

- 設計一個 Validator Class，
- 用這個 Class 產生一個實例 validator，
- 呼叫 validator.valid?
- 如果通過驗証會回傳 true
- 若不通過驗証會回傳 false，並且
- 可以透過 validator.errors 得到 invalid 的 error 訊息

### 開發建議

這支程式已有基本的雛型，它被分為兩個 class：TableInfo 以及 CsvValidator

以及建議設計的公開介面方法，包含 initializer

- CsvValidator 會是主要與外界互動的對象
- TableInfo 則是預先引導你的設計：將 schema 資訊封裝成物件，方便你去篩選出 schema 中需要的欄位或資訊，例如
  - 取得屬於 time 格式的欄位
  - 取得屬於 not null 的欄位

程式的主要流程會是

- 傳入 CSV 檔案路徑以及 TableInfo object 來產生 CsvValidator
- 呼叫 CsvValidator#valid? 來判斷該 CSV 檔是否通過驗証，以及
- 呼叫 CsvValidator#errors 來取得驗証失敗的錯誤訊息 (若驗証通過則 errors 會回傳空陣列)

你的工作主要就是完成這兩個 class 的內部實作

- lib/table_info.rb
- lib/csv_validator.rb

 (當然如果你需要增加其他的 class 也是可以的)

兩個 class 分別有對應的 spec 檔案，你需要讓它們通過 rspec 測試 (但這兩個檔案你不需要去修改它)

- spec/lib/table_info_spec.rb
- spec/lib/csv_validator_spec.rb

建議先從通過 TableInfo 的測試開始 (就是先寫 TableInfo Class 的意思)

你可以用指定檔案的方式單獨執行其中的 RSpec 測試，例如

```
bundle exec rspec spec/lib/table_info_spec.rb
bundle exec rspec spec/lib/csv_validator_spec.rb
```

當然，最終的目的是同時通過兩個檔案的測試

```
bundle exec rspec
```

在 CsvValidator 的測試中有六個案例

即代表1個驗証成功，以及另外5種驗証失敗的案例

它們分別使用了 spec/fixtures/csv/ 下的六個 csv 檔案當作測試素材

5種驗証失敗的案例即對應到 `情境` 說明中的那 `五種條件`

### 備註

[1] schema 資訊會先以 hash 的形式存在於程式中，可以參考 spec 檔案中的 `let(:schema) ...` 宣告；例如

```
  {
    'id' => { type: 'integer', auto_increament: true, null: false },
    'name' => { type: 'string', null: true, limit: 20 },
    'description' => { type: 'string', null: true, limit: 255 },
    'character_id' => { type: 'integer', null: false },
    'start_at' => { type: 'datetime' },
    'end_at' => { type: 'datetime' }
  }
```

代表資料表有 id, name, description, character_id, start_at, end_at 六個欄位，以及它們各自的欄位定義

[2] 多語言欄位(localized fields)會在 CSV 檔案的 header 中，以 xxx[aa], xxx[bb] .. 的格式命名，其中 xxx 為對應在資料表 schema 的欄位名稱，aa、bb 則是語言代碼，

例如在 CSV 中 header 若包含 title[en], title[zh]，

即代表資料表中的 title 欄位是一個多語言欄位，而在 CSV 中的資料列會同時包含 英文(en)、中文(zh) 的 title 內容

> 提示：你可能會需要使用 `正規表示式` 對 header name 判斷它是不是 localized field，並取出其對應的 `欄位名稱` 和 `語言代碼`
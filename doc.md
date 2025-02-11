# Thorn-private-sale Research
## Tìm hiểu về private sale
 - Private sale là giai đoạn huy động vốn đầu tiên của một dự án crypto, trong đó token được bán riêng cho các nhà đầu tư giàu có, quỹ đầu tư mạo hiểm, tổ chức tài chính,...
 - Đây là giai đoạn kín, với giá token ưu đãi hơn so với vòng công khai, nhưng đi kèm với điều kiện như thời gian khóa token (lock-up period - khoảng thời gian không thể giao dịch hay chuyển nhượng) và lịch phát hành (vesting schedule)
 - Vesting có 2 kiểu phổ biến: Cliff vesting và Linear vesting (Thorn Presale theo kiểu Cliff vesting), Cliff Vesting có 1 khoảng thời gian đóng sau khi phát hành token và sau đó sẽ phát hành token theo lịch trình đã định.
## Cơ chế hoạt động
### Mua Token trong Presale
- Người dùng thực hiện giao dịch để mua token THORN trong khoảng thời gian cho phép, thỏa mãn các điều kiện mua. (thuộc whitelist, danh sách khách hàng dặt trước của launchpad,...)
 Các Bước Chính:
 1. Người dùng đăng nhập vào giao diện bán token của hệ thống.
 2. Người dùng chọn số lượng tài sản muốn gửi để mua token THORN.
 3. Người dùng xác nhận việc giao dịch và gửi tài sản từ ví của mình.
 4. Hệ thống hiển thị số lượng token THORN mà người dùng sẽ nhận được sau giao dịch.
 5. Người dùng xác nhận giao dịch và thấy thông báo thành công cùng thông tin chi tiết:
 - Số lượng tài sản gửi vào.
 - Số lượng token THORN đã mua.
 - Thông tin vesting (lịch trả token).
 6. Giao diện cập nhật số token THORN có thể claim ngay tại thời điểm TGE (Token Generation Event) và số
 còn lại sẽ được khóa.
 - Điều kiện Thành công:  Người dùng hoàn tất giao dịch và sở hữu số token THORN đã mua
 
 - `Các trường hợp không thành công`:
     1.  Người Dùng Không Thuộc Danh Sách Trắng (Whitelist) thì Hệ thống kiểm tra danh sách trắng và thông báo: “User is not in whitelist to buy bond.”
     2. Đợt Mua Đã Hết Hạn Hoặc Chưa Bắt Đầu:
        - Hệ thống kiểm tra thời gian bán token và thông báo:
 + “It's not time to buy token in this terms yet!” nếu thời gian hiện tại trước thời gian cho phép.
 + “terms private sale is expired!” nếu thời gian hiện tại sau thời gian cho phép.
     3. Vượt Giới Hạn Mua Token: “THORN too max” nếu số token muốn mua vượt quá giới hạn cho phép cho
 một người dùng hoặc  “Max Capacity has reached” nếu tổng nợ đã đạt đến giới hạn.
     4. Địa chỉ ví không hợp lệ
   ### Rút token sau khi mua
    - Cho phép người dùng rút token đã mua trong đợt bán riêng theo thời gian cliff và vesting quy định
      
### Use-case các contract
#### BondDepository:
- Quản lí cơ chế hoạt động trái phiếu
- Công thức giá bond:
![image](https://github.com/user-attachments/assets/d502257f-bb8b-4406-ab4c-4fc775c86135)
- Với: `Ci` là số token còn lại để bán ở thời điểm i
- `Ti` thời gian còn lại ở thời điểm i
- `Pi` giá tại thời điểm i (tính theo $)
-  Suy ra, Giá bond `Pa` tại thời điểm a tỉ lệ thuận với tỉ số giữa thời gian còn lại `Ta` và số token còn lại tại thời điểm a  là `Ca`. Do đó, khi số token còn lại giảm hoặc thời gian còn lại ít đi, giá trái phiếu có xu hướng tăng lên. Điều này khuyến khích người mua tham gia sớm để có mức giá tốt hơn.
#### ThornERC20
- Contract token ERC20 của Thorn.
#### TokenPrice
- Xác định giá token (lấy giá từ Oracle,vd: Aave Oracle; Tính giá từ cặp LP token nếu không có Oracle hỗ trợ, đặt giá cố định cho THORN token (0.02 USDT)).
- Hỗ trợ quản lí LP Token (lưu thông tin, xác định cặp token để tính giá).
- Thêm/xóa token khỏi danh sách có thể lấy giá từ Oracle.
#### Treasury
- Nắm giữ và quản lí tài sản của dự án:
- Gửi tài sản vào Treasury ( deposit ).
- Rút tài sản (manage)
- Mint phần thưởng
- Kiểm toán dự trữ, cập nhật tổng số dư dự trữ (auditReserves).
- Quản lí quyền 
#### PrivateSaleRoundOne
- Quản lí vòng Presale, các chức năng bao gồm:
- Mua token THORN bằng USDT theo mức giá ưu đãi, có vesting.
- Quản lý whitelist để kiểm soát người mua (có thể bật/tắt).
- Thiết lập các điều kiện vesting & cliffing (thời gian khóa và giải ngân).
- Tính toán và theo dõi số lượng THORN đã mua, đã nhận và còn lại của từng người.
- Rút token bị kẹt và cập nhật các thông số của private sale.
#### PrivateSaleRoundThree
- Quản lí vòng Presale (tương tự v1)
#### PrivateSaleRoundFour
- Quản lí vòng Presale (tương tự v1)
#### Policy
- Quản lý quyền quản trị, cho phép kiểm tra owner, từ bỏ quyền, đề xuất và chấp nhận quản trị viên mới.
#### PolicyUpgradeable
- Proxy của Policy. (nâng cấp mà không mất dữ liệu trước đó).
## Thiết kế contract
### Các thuộc tính quan trọng
#### BondDepository
##### Thuộc tính:
| Tên biến         | Kiểu dữ liệu                            | Mô tả |
|-----------------|--------------------------------------|------|
| `staking`       | `address`                           | Địa chỉ của contract staking. |
| `stakingHelper` | `address`                           | Địa chỉ của contract staking helper. |
| `useHelper`     | `bool`                              | Cờ cho biết có sử dụng staking helper hay không. |
| `Thorn`        | `address`                           | Token chính được sử dụng trong bond. |
| `DAO`          | `address`                           | Địa chỉ của tổ chức DAO nhận doanh thu từ bond. |
| `principals`   | `address[]`                         | Danh sách các địa chỉ token gốc được chấp nhận để mua bond. |
| `terms`        | `mapping(address => Terms)`         | Mapping lưu trữ điều khoản bond cho từng token gốc. |
| `totalDebt`    | `uint256`                           | Tổng số nợ chưa thanh toán từ bond. |
| `lastDecay`    | `uint256`                           | Thời gian cuối cùng nợ bond được giảm dần. |
| `bondInfo`     | `mapping(address => mapping(address => Bond))` | Mapping lưu thông tin bond của từng người dùng với từng token gốc. |
| `whitelist`    | `mapping(address => bool)`          | Mapping danh sách địa chỉ được phép mua bond. |

 - P/s: Whitelist: danh sách địa chỉ được phép tham gia vào sự kiện.
- Struct:
- Terms:
  
| Tên biến     | Kiểu dữ liệu | Mô tả |
|-------------|------------|------|
| `controlVariable` | `uint256` | Biến kiểm soát tỷ lệ chiết khấu của bond. |
| `vestingTerm`     | `uint256` | Thời gian khóa của bond tính bằng giây. |
| `minimumPrice`    | `uint256` | Giá tối thiểu của bond. |
| `maxPayout`       | `uint256` | Phần trăm tối đa của `Thorn` có thể nhận được từ bond. |
| `fee`            | `uint256` | Phí DAO thu trên mỗi giao dịch bond. |
| `maxDebt`        | `uint256` | Tổng nợ tối đa mà bond có thể phát hành. |

- Bond:
  
| Tên biến   | Kiểu dữ liệu | Mô tả |
|-----------|------------|------|
| `payout`  | `uint256`  | Số lượng `Thorn` mà người dùng sẽ nhận được khi bond đáo hạn. |
| `vesting` | `uint256`  | Thời gian khóa còn lại của bond. |
| `lastBlock` | `uint256` | Block cuối cùng mà người dùng claim bond. |

#### ThornERC20
| Tên biến     | Kiểu dữ liệu | Mô tả |
|-------------|------------|------|
| `_totalSupply` | `uint256` | Tổng cung của token Thorn. |
| `_balances` | `mapping(address => uint256)` | Mapping lưu số dư token của từng địa chỉ. |

#### TokenPrice
| Tên biến                        | Kiểu dữ liệu                        | Mô tả |
|---------------------------------|---------------------------------|------|
| `USDT_ADDRESS`                  | `address`                      | Địa chỉ contract của USDT. |
| `AAVE_ORACLE`                   | `address`                      | Địa chỉ contract của Aave Oracle. |
| `ILLUMINEX_ROUTER`              | `address`                      | Địa chỉ contract của Illuminex Router. |
| `THORN_ADDRESS`                 | `address`                      | Địa chỉ contract của token THORN. |
| `THORN_PRICE`                   | `uint`                         | Giá của token THORN. |
| `supportTokensPriceOracle`      | `mapping(address => bool)`      | Mapping xác định token nào được hỗ trợ bởi oracle giá. |
| `lpTokens`                      | `mapping(address => LpInfo)`    | Mapping lưu thông tin về LP Token của từng token. |
- Struct:
  
| Tên Struct  | Thuộc tính        | Kiểu dữ liệu | Mô tả |
|------------|------------------|------------|------|
| `LpInfo`   | `lpToken`        | `address`  | Địa chỉ của Liquidity Pool (LP) Token. |
|            | `otherHalf`       | `address`  | Địa chỉ của token còn lại trong cặp LP. |
#### Treasury

| Tên biến                        | Kiểu dữ liệu                        | Mô tả |
|---------------------------------|---------------------------------|------|
| `owner`                         | `address`                      | Địa chỉ của chủ sở hữu contract. |
| `pendingOwner`                  | `address`                      | Địa chỉ của chủ sở hữu đang chờ xác nhận. |
| `USDT_ADDRESS`                  | `address`                      | Địa chỉ contract của USDT. |
| `AAVE_ORACLE`                   | `address`                      | Địa chỉ contract của Aave Oracle. |
| `ILLUMINEX_ROUTER`              | `address`                      | Địa chỉ contract của Illuminex Router. |
| `THORN_ADDRESS`                 | `address`                      | Địa chỉ contract của token THORN. |
| `THORN_PRICE`                   | `uint256`                      | Giá của token THORN (có thể theo đơn vị nhỏ nhất). |
| `THORN_DECIMALS`                | `uint256`                      | Số chữ số thập phân của THORN token. |
| `DENOMINATOR`                   | `uint256`                      | Hằng số dùng để tính toán (có thể là 10^18 hoặc tương tự). |
| `tax`                           | `uint256`                      | Mức thuế áp dụng trên giao dịch (tính theo phần trăm hoặc phần nghìn). |
| `swapSlippage`                  | `uint256`                      | Độ trượt giá tối đa khi swap. |
| `minThornAmount`                | `uint256`                      | Lượng THORN tối thiểu yêu cầu để thực hiện một số thao tác. |
| `isThornPriceActive`            | `bool`                         | Biến boolean kiểm soát việc có sử dụng THORN price hay không. |
| `supportTokensPriceOracle`      | `mapping(address => bool)`      | Mapping xác định token nào được hỗ trợ bởi oracle giá. |
| `lpTokens`                      | `mapping(address => LpInfo)`    | Mapping lưu thông tin về LP Token của từng token. |
| `lpTokenList`                   | `address[]`                    | Danh sách địa chỉ của các LP Token. |
- Struct:
  
| **Structs** |  Kiểu dữ liệu | Mô tả |
|---------------------------------|---------------------------------|------|
| `struct LpInfo`                 | `struct`                       | Struct lưu trữ thông tin của một LP Token. |
| `LpInfo.token0`                 | `address`                      | Địa chỉ của token0 trong LP. |
| `LpInfo.token1`                 | `address`                      | Địa chỉ của token1 trong LP. |
| `LpInfo.isSupported`            | `bool`                         | LP Token có được hỗ trợ hay không. |

#### PrivateSaleRoundOne
### **Biến quan trọng**
| Tên biến                   | Kiểu dữ liệu  | Mô tả |
|----------------------------|--------------|------|
| `thornPrice`               | `uint256`    | Giá của token THORN (decimal = 2). |
| `totalDebt`                | `uint256`    | Tổng số THORN đã được bán ra. |
| `principle`                | `address`    | Địa chỉ contract của token USDT. |
| `Thorn`                    | `address`    | Địa chỉ contract của token THORN. |
| `terms`                    | `Terms`      | Cấu trúc chứa thông tin về đợt private sale. |
| `bondInfo`                 | `mapping(address => PriSale)` | Mapping lưu thông tin mua token của mỗi user. |
| `isWhiteList`              | `mapping(address => bool)` | Mapping kiểm tra user có trong whitelist hay không. |
| `isUseWhiteList`           | `bool`       | Biến kiểm soát việc sử dụng whitelist. |

##### **Struct**
##### `Terms`
| Tên biến                   | Kiểu dữ liệu  | Mô tả |
|----------------------------|--------------|------|
| `buyingTimeStart`          | `uint`       | Thời gian bắt đầu mua. |
| `buyingTime`               | `uint`       | Thời gian kéo dài của đợt mua. |
| `vestingTimeStart`         | `uint`       | Thời gian bắt đầu vesting. |
| `vestingTerm`              | `uint`       | Thời gian vesting. |
| `cliffingTimeStart`        | `uint`       | Thời gian bắt đầu cliffing. |
| `cliffingTerm`             | `uint`       | Thời gian cliffing. |
| `discountRatio`            | `uint`       | Tỉ lệ giảm giá (tối đa 50%). |
| `maxDebt`                  | `uint`       | Giới hạn tối đa của debt. |
| `maxPayout`                | `uint`       | Số THORN tối đa một user có thể mua. |
| `TGE`                      | `uint`       | Tỉ lệ THORN được claim ngay lập tức khi mua. |

##### `PriSale`
| Tên biến                   | Kiểu dữ liệu  | Mô tả |
|----------------------------|--------------|------|
| `totalBought`              | `uint`       | Tổng số THORN đã mua. |
| `amountClaim`              | `uint`       | Số lượng THORN đã được claim. |
| `payout`                   | `uint`       | Số lượng THORN còn lại để vesting. |
| `vesting`                  | `uint`       | Số block còn lại trong vesting. |
| `lastBlock`                | `uint`       | Block cuối cùng user claim. |
| `pricePaid`                | `uint`       | Số lượng USDT đã thanh toán. |

#### PrivateSaleRoundThree
##### Tương tự Round 1
#### PrivateSaleRoundFour
##### Tương tự Round 1
#### Policy

| Tên biến                   | Kiểu dữ liệu  | Mô tả |
|----------------------------|--------------|------|
| `_policy`                  | `address`    | Địa chỉ của policy hiện tại (quyền sở hữu contract). |
| `_newPolicy`               | `address`    | Địa chỉ policy mới đang chờ xác nhận. |

### Các use-case quan trọng
#### BondDepository
### Công thức sử dụng
### Các hàm quan trọng và ý nghĩa

#### initialize
**Input:**
| Parameter | Meaning |
|-----------|---------|
| _admin | Địa chỉ admin của hợp đồng |
| _oracle | Địa chỉ oracle cung cấp dữ liệu |

**Output:**
- Khởi tạo hợp đồng với admin và oracle.

**Các công việc thực hiện:**
1. Đặt admin và oracle.
2. Thiết lập trạng thái ban đầu của hợp đồng.



#### pause
**Input:**
- Không có.

**Output:**
- Tạm dừng hợp đồng.

**Các công việc thực hiện:**
1. Kiểm tra quyền hạn của người gọi.
2. Đặt trạng thái hợp đồng thành "tạm dừng".



#### unpauseContract
**Input:**
- Không có.

**Output:**
- Kích hoạt lại hợp đồng.

**Các công việc thực hiện:**
1. Kiểm tra quyền hạn của người gọi.
2. Đặt trạng thái hợp đồng thành "hoạt động".



#### initializeBondTerms
**Input:**
| Parameter | Meaning |
|-----------|---------|
| _term1 | Giá trị điều khoản 1 |
| _term2 | Giá trị điều khoản 2 |
| _term3 | Giá trị điều khoản 3 |
| _term4 | Giá trị điều khoản 4 |
| _term5 | Giá trị điều khoản 5 |
| _term6 | Giá trị điều khoản 6 |
| _term7 | Giá trị điều khoản 7 |

**Output:**
- Thiết lập các điều khoản trái phiếu ban đầu.

**Các công việc thực hiện:**
1. Lưu trữ các điều khoản trái phiếu vào biến trạng thái.
2. Kiểm tra và xác thực đầu vào.



#### setBondTerms
**Input:**
| Parameter | Meaning |
|-----------|---------|
| _index | Chỉ số điều khoản cần thay đổi |
| _value | Giá trị mới của điều khoản |

**Output:**
- Cập nhật điều khoản trái phiếu.

**Các công việc thực hiện:**
1. Kiểm tra quyền admin.
2. Cập nhật giá trị điều khoản tương ứng.



#### setStaking
**Input:**
| Parameter | Meaning |
|-----------|---------|
| _staking | Địa chỉ hợp đồng staking |
| _status | Trạng thái bật/tắt |

**Output:**
- Cập nhật địa chỉ staking.

**Các công việc thực hiện:**
1. Kiểm tra quyền admin.
2. Cập nhật trạng thái staking.



#### setThornAddress
**Input:**
| Parameter | Meaning |
|-----------|---------|
| _thorn | Địa chỉ token THORN |

**Output:**
- Cập nhật địa chỉ token THORN.

**Các công việc thực hiện:**
1. Kiểm tra quyền admin.
2. Cập nhật địa chỉ token.



#### setPrincipleAddress
**Input:**
| Parameter | Meaning |
|-----------|---------|
| _principle | Địa chỉ token nguyên tắc |

**Output:**
- Cập nhật địa chỉ token nguyên tắc.

**Các công việc thực hiện:**
1. Kiểm tra quyền admin.
2. Cập nhật địa chỉ token.



#### deposit
**Input:**
| Parameter | Meaning |
|-----------|---------|
| _amount | Số lượng token gửi |
| _maxPrice | Giá tối đa chấp nhận |
| _recipient | Địa chỉ nhận |

**Output:**
- Gửi token vào hợp đồng.

**Các công việc thực hiện:**
1. Kiểm tra số dư.
2. Chuyển token vào hợp đồng.



#### redeem
**Input:**
| Parameter | Meaning |
|-----------|---------|
| _recipient | Địa chỉ nhận token |

**Output:**
- Rút token về địa chỉ chỉ định.

**Các công việc thực hiện:**
1. Kiểm tra điều kiện rút.
2. Chuyển token về cho người dùng.



#### getAssetPrice
**Input:**
| Parameter | Meaning |
|----------|----------------------|
| _asset   | Địa chỉ của token cần lấy giá |

**Output:**
- Trả về giá của `_asset` tính theo USDT.

**Các công việc thực hiện:**
1. Nếu `_asset` là `THORN_ADDRESS`, trả về giá trị cố định là **0.02 USDT**.
2. Nếu `_asset` là `USDT_ADDRESS`, trả về giá trị **1 USDT**.
3. Nếu `_asset` được hỗ trợ bởi oracle:
   - Gọi `IAaveOracle(AAVE_ORACLE).getAssetPrice(_asset)`.
   - Điều chỉnh giá trị theo số thập phân của USDT.
   - Trả về giá trị tính được.
4. Nếu `_asset` không được hỗ trợ bởi oracle:
   - Lấy địa chỉ `lpToken` và `otherHalf` từ `lpTokens[_asset]`.
   - Lấy số dư `_asset` trong pool LP (`balanceTokenA`).
   - Lấy số dư `otherHalf` trong pool LP (`balanceTokenB`).
   - Lấy giá `otherHalf` từ `AAVE_ORACLE`.
   - Tính giá `_asset` dựa trên tỷ lệ giữa hai token trong pool:
    ```math
    price = \frac{balanceTokenB \times priceOtherHalf}{balanceTokenA}
    ```
   - Trả về giá trị tính được.



#### getPayout
**Input:**
| Parameter | Meaning |
|-----------|---------|
| _amount | Số lượng token đầu vào |

**Output:**
- Trả về số token được nhận khi gửi vào `_amount`.

**Các công việc thực hiện:**
1. Tính toán payout dựa trên công thức nội bộ.
2. Trả về giá trị.



#### getWhitelistStatus
**Input:**
| Parameter | Meaning |
|-----------|---------|
| _user | Địa chỉ người dùng |

**Output:**
- Trả về trạng thái whitelist của người dùng.

**Các công việc thực hiện:**
1. Kiểm tra danh sách whitelist.
2. Trả về kết quả.



#### getWithdrawableAmount
**Input:**
| Parameter | Meaning |
|-----------|---------|
| _user | Địa chỉ người dùng |

**Output:**
- Trả về số lượng có thể rút của người dùng.

**Các công việc thực hiện:**
1. Kiểm tra số dư khả dụng.
2. Tính toán lượng có thể rút.
3. Trả về kết quả.


### TokenPrice
##### Công thức sử dụng

#### initialize
**Input:**
| Parameter      | Meaning                        |
|--------------|--------------------------------|
| _usdtAddress  | Địa chỉ của token USDT        |
| _thornAddress | Địa chỉ của token ThornUSD    |

**Các công việc thực hiện:**
- Khởi tạo hợp đồng với hai địa chỉ token `USDT_ADDRESS` và `THORN_ADDRESS`.
- Lưu giá trị của các địa chỉ vào biến trạng thái tương ứng.



#### setAaveOracle
**Input:**
| Parameter   | Meaning                      |
|------------|------------------------------|
| _aaveOracle | Địa chỉ của Aave Oracle mới |

**Các công việc thực hiện:**
1. Kiểm tra `msg.sender` có quyền `onlyPolicy`.
2. Kiểm tra `_aaveOracle` hợp lệ (khác `address(0)` và khác địa chỉ cũ).
3. Cập nhật địa chỉ `AAVE_ORACLE` thành `_aaveOracle`.



#### setSupportTokenOraclePrice
**Input:**
| Parameter | Meaning                          |
|----------|----------------------------------|
| _token   | Địa chỉ của token                |
| _status  | Trạng thái hỗ trợ (true/false)   |

**Các công việc thực hiện:**
1. Kiểm tra `msg.sender` có quyền `onlyPolicy`.
2. Kiểm tra `_token` hợp lệ (khác `address(0)` và khác trạng thái cũ).
3. Cập nhật trạng thái hỗ trợ giá oracle của `_token` trong `supportTokensPriceOracle`.



#### getLpToken
**Input:**
| Parameter | Meaning               |
|----------|-----------------------|
| _token   | Địa chỉ của token cần tra cứu |

**Output:**
- Trả về thông tin `LpInfo` của `_token` gồm `lpToken` và `otherHalf`.

**Các công việc thực hiện:**
1. Trả về thông tin của `_token` từ mapping `lpTokens`.


#### setLpTokens
**Input:**
| Parameter       | Meaning                               |
|---------------|---------------------------------------|
| _tokenA       | Token chính trong cặp LP            |
| _multiLpTokens | Thông tin cặp LP (`lpToken`, `otherHalf`) |

**Các công việc thực hiện:**
1. Kiểm tra `msg.sender` có quyền `onlyPolicy`.
2. Kiểm tra `_tokenA` hợp lệ (`address(0)` không được chấp nhận).
3. Kiểm tra `_tokenA` chưa được hỗ trợ bởi oracle.
4. Kiểm tra `otherHalf` của `_multiLpTokens` phải là token được hỗ trợ bởi oracle.
5. Cập nhật thông tin cặp LP vào mapping `lpTokens`.



#### getAssetPrice
**Input:**
| Parameter | Meaning              |
|----------|----------------------|
| _asset   | Địa chỉ của token cần lấy giá |

**Output:**
- Trả về giá của `_asset` tính theo USDT.

**Các công việc thực hiện:**
1. Nếu `_asset` là `THORN_ADDRESS`, trả về giá trị cố định là **0.02 USDT**.
2. Nếu `_asset` là `USDT_ADDRESS`, trả về giá trị **1 USDT**.
3. Nếu `_asset` được hỗ trợ bởi oracle:
   - Gọi `IAaveOracle(AAVE_ORACLE).getAssetPrice(_asset)`.
   - Điều chỉnh giá trị theo số thập phân của USDT.
   - Trả về giá trị tính được.
4. Nếu `_asset` không được hỗ trợ bởi oracle:
   - Lấy địa chỉ `lpToken` và `otherHalf` từ `lpTokens[_asset]`.
   - Lấy số dư `_asset` trong pool LP (`balanceTokenA`).
   - Lấy số dư `otherHalf` trong pool LP (`balanceTokenB`).
   - Lấy giá `otherHalf` từ `AAVE_ORACLE`.
   - Tính giá `_asset` dựa trên tỷ lệ giữa hai token trong pool:
    ![image](https://github.com/user-attachments/assets/1ad630e6-5903-4c97-a4d4-b89e256749c7)

   - Trả về giá trị tính được.



#### _getAssetPriceUsdt (Internal)
**Input:**
| Parameter | Meaning              |
|----------|----------------------|
| _asset   | Địa chỉ của token cần lấy giá |

**Output:**
- Trả về giá của `_asset` tính theo USDT.

**Các công việc thực hiện:**
1. Kiểm tra nếu `_asset` có hỗ trợ oracle:
   - Gọi `ILuminexRouter(ILLUMINEX_ROUTER).getAmountsOut()` để lấy giá trị quy đổi sang USDT.
   - Điều chỉnh giá trị theo số thập phân của USDT.
   - Trả về giá trị tính được.
2. Nếu không hỗ trợ oracle, trả về giá trị `0`.

### Treasury 
### Use Cases for Treasury Contract



#### _deposit
**Input:**
| Parameter | Meaning |
|-----------|---------|
| `token`   | Địa chỉ của token được nạp vào Treasury |
| `amount`  | Số lượng token được nạp |

**Các công việc thực hiện:**
- Kiểm tra xem token có được hỗ trợ không.
- Chuyển `amount` token từ người gửi vào Treasury.
  ```solidity
  IERC20(token).transferFrom(msg.sender, address(this), amount);
  ```
- Cập nhật số dư của Treasury:
  ```solidity
  balances[token] += amount;
  ```



#### _withdraw
**Input:**
| Parameter | Meaning |
|-----------|---------|
| `token`   | Địa chỉ của token được rút |
| `amount`  | Số lượng token được rút |
| `to`      | Địa chỉ nhận token rút ra |

**Các công việc thực hiện:**
- Kiểm tra xem Treasury có đủ số dư không:
  ```solidity
  require(balances[token] >= amount, "Insufficient balance");
  ```
- Giảm số dư của Treasury:
  ```solidity
  balances[token] -= amount;
  ```
- Chuyển token đến địa chỉ `to`:
  ```solidity
  IERC20(token).transfer(to, amount);
  ```



#### _allocateFunds
**Input:**
| Parameter | Meaning |
|-----------|---------|
| `proposalId` | ID của proposal được cấp vốn |
| `token`      | Địa chỉ của token được sử dụng cấp vốn |
| `amount`     | Số lượng token được phân bổ |

**Các công việc thực hiện:**
- Kiểm tra trạng thái của proposal:
  ```solidity
  require(proposals[proposalId].status == ProposalStatus.Approved, "Proposal not approved");
  ```
- Giảm số dư Treasury:
  ```solidity
  balances[token] -= amount;
  ```
- Cập nhật thông tin tài trợ cho proposal:
  ```solidity
  proposals[proposalId].allocatedFunds[token] += amount;
  ```



#### _checkBalance
**Input:**
| Parameter | Meaning |
|-----------|---------|
| `token`   | Địa chỉ của token cần kiểm tra số dư |

**Các công việc thực hiện:**
- Trả về số dư hiện tại của Treasury:
  ```solidity
  return balances[token];
  ```



#### _transferOwnership
**Input:**
| Parameter | Meaning |
|-----------|---------|
| `newOwner` | Địa chỉ của chủ sở hữu mới |

**Các công việc thực hiện:**
- Xác minh quyền của người gọi (chỉ chủ sở hữu hiện tại mới được phép gọi hàm):
  ```solidity
  require(msg.sender == owner, "Not authorized");
  ```
- Cập nhật chủ sở hữu mới:
  ```solidity
  owner = newOwner;
  ```
- Phát sự kiện `OwnershipTransferred`:
  ```solidity
  emit OwnershipTransferred(msg.sender, newOwner);
  ```



#### _getProposalStatus
**Input:**
| Parameter | Meaning |
|-----------|---------|
| `proposalId` | ID của proposal cần kiểm tra trạng thái |

**Các công việc thực hiện:**
- Lấy trạng thái của proposal từ mapping:
  ```solidity
  return proposals[proposalId].status;
  ```



#### _approveProposal
**Input:**
| Parameter | Meaning |
|-----------|---------|
| `proposalId` | ID của proposal cần phê duyệt |

**Các công việc thực hiện:**
- Xác minh quyền của người gọi (chỉ admin mới được phép gọi hàm):
  ```solidity
  require(msg.sender == admin, "Not authorized");
  ```
- Thay đổi trạng thái của proposal:
  ```solidity
  proposals[proposalId].status = ProposalStatus.Approved;
  ```
- Phát sự kiện `ProposalApproved`:
  ```solidity
  emit ProposalApproved(proposalId);
  ```



#### _rejectProposal
**Input:**
| Parameter | Meaning |
|-----------|---------|
| `proposalId` | ID của proposal cần từ chối |

**Các công việc thực hiện:**
- Xác minh quyền của người gọi (chỉ admin mới được phép gọi hàm):
  ```solidity
  require(msg.sender == admin, "Not authorized");
  ```
- Thay đổi trạng thái của proposal:
  ```solidity
  proposals[proposalId].status = ProposalStatus.Rejected;
  ```
- Phát sự kiện `ProposalRejected`:
  ```solidity
  emit ProposalRejected(proposalId);
  ```


## PrivateSaleRoundOne
## Các hàm quan trọng và ý nghĩa
## 1.Quản lý vòng Private Sale
### 1.1 `initializePrivateSaleRound`
**Mô tả:**  
Khởi tạo vòng private sale với các thông số cơ bản.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_startTime` | Thời gian bắt đầu vòng sale |
| `_endTime` | Thời gian kết thúc vòng sale |
| `_vestingCliff` | Thời gian cliff trước khi có thể claim token |
| `_vestingDuration` | Tổng thời gian vesting |
| `_minPurchase` | Số lượng tối thiểu được phép mua |
| `_maxPurchase` | Số lượng tối đa được phép mua |
| `_totalAllocation` | Tổng số token THORN phân bổ cho vòng sale |
| `_payoutRate` | Tỷ lệ quy đổi từ USDT sang THORN |
| `_usdtAddress` | Địa chỉ token USDT |
| `_thornAddress` | Địa chỉ token THORN |

**Output:**  
- Không có.

**Các công việc thực hiện:**  
1. Lưu trữ thông tin của vòng private sale.  
2. Kiểm tra các thông số hợp lệ.  
3. Gửi sự kiện `PrivateSaleInitialized`.  


### 1.2 `setPrivateSale`
**Mô tả:**  
Cập nhật trạng thái vòng private sale.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_status` | Trạng thái mới của vòng sale |
| `_maxPurchase` | Giới hạn mua tối đa mới |

**Output:**  
- Không có.

**Các công việc thực hiện:**  
1. Cập nhật trạng thái của vòng private sale.  
2. Cập nhật giới hạn mua tối đa.  
3. Gửi sự kiện `PrivateSaleStatusUpdated`.  


### 1.3 `setThornPrice`
**Mô tả:**  
Thiết lập giá của token THORN trong vòng Private Sale.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_price` | Giá của THORN tính bằng USDT |

**Output:**  
- Không có.

**Các công việc thực hiện:**  
1. Cập nhật giá THORN.  
2. Gửi sự kiện `ThornPriceUpdated`.  


### 1.4 `setThornAddress`
**Mô tả:**  
Cập nhật địa chỉ contract của token THORN.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_thornAddress` | Địa chỉ mới của token THORN |

**Output:**  
- Không có.

**Các công việc thực hiện:**  
1. Cập nhật địa chỉ của token THORN.  
2. Gửi sự kiện `ThornAddressUpdated`.  



### 1.5 `setUsdtAddress`
**Mô tả:**  
Cập nhật địa chỉ contract của token USDT.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_usdtAddress` | Địa chỉ mới của token USDT |

**Output:**  
- Không có.

**Các công việc thực hiện:**  
1. Cập nhật địa chỉ của token USDT.  
2. Gửi sự kiện `UsdtAddressUpdated`.  



### 1.6 `withdrawStuckAmount`
**Mô tả:**  
Admin rút số lượng token bị kẹt khỏi hợp đồng.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_amount` | Số lượng token muốn rút |
| `_tokenAddress` | Địa chỉ của token muốn rút |

**Output:**  
- Không có.

**Các công việc thực hiện:**  
1. Kiểm tra quyền admin.  
2. Rút số token bị kẹt trong hợp đồng.  
3. Gửi sự kiện `StuckAmountWithdrawn`.  



### 1.7 `toggleWhitelisted`
**Mô tả:**  
Thêm hoặc loại bỏ một địa chỉ khỏi whitelist.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_user` | Địa chỉ cần thêm hoặc loại bỏ khỏi whitelist |

**Output:**  
- Không có.

**Các công việc thực hiện:**  
1. Cập nhật trạng thái whitelist của `_user`.  
2. Gửi sự kiện `WhitelistUpdated`.  



### 1.8 `toggleUseWhiteList`
**Mô tả:**  
Bật hoặc tắt chế độ whitelist cho vòng private sale.

**Input:**  
- Không có.

**Output:**  
- Không có.

**Các công việc thực hiện:**  
1. Cập nhật trạng thái whitelist toàn cầu.  
2. Gửi sự kiện `WhitelistToggled`.  



### 1.9 `deposit`
**Mô tả:**  
Mua token Thorn trong vòng private sale.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_amount` | Số USDT dùng để mua token |
| `_depositor` | Địa chỉ người mua |

**Output:**  
- Số lượng token Thorn nhận được.

**Các công việc thực hiện:**  
1. Kiểm tra thời gian mua có hợp lệ không.  
2. Kiểm tra whitelist nếu được bật.  
3. Kiểm tra `_amount` có vượt quá giới hạn không.  
4. Chuyển USDT từ `_depositor` vào hợp đồng.  
5. Cập nhật trạng thái giao dịch trong `bondInfo`.  
6. Gửi sự kiện `PrivateSaleBuy`.  



### 1.10 `redeem`
**Mô tả:**  
Người dùng rút số lượng token đã mua theo lịch vesting.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_recipient` | Địa chỉ nhận token |

**Output:**  
- Số lượng token đã nhận.

**Các công việc thực hiện:**  
1. Tính toán số lượng token có thể rút theo vesting.  
2. Chuyển token THORN vào `_recipient`.  
3. Cập nhật trạng thái của bond.  
4. Gửi sự kiện `PrivateSaleRedeem`.
## 2. Truy vấn thông tin người dùng  
### 2.1 `percentVestedFor`
**Mô tả:**  
Lấy phần trăm token đã được mở khóa cho một địa chỉ cụ thể.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_user` | Địa chỉ cần kiểm tra |

**Output:**  
- Phần trăm token đã được mở khóa.

**Công thức:**  
- Nếu `block.timestamp < vestingCliff`, phần trăm mở khóa = 0%.  
- Ngược lại, phần trăm mở khóa được tính theo công thức:  
![image](https://github.com/user-attachments/assets/165e6ccf-98f5-4242-b82c-821577a7c7d6)
**Các công việc thực hiện:**  
1. Kiểm tra xem thời gian cliff đã kết thúc chưa.  
2. Nếu vesting đã bắt đầu, tính phần trăm vesting theo công thức.  
3. Trả về giá trị phần trăm đã mở khóa.  



### 2.2 `getTotalReceived`
**Mô tả:**  
Trả về tổng số USDT mà người dùng đã gửi vào hợp đồng.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_user` | Địa chỉ người dùng |

**Output:**  
- Tổng số USDT đã gửi.

**Các công việc thực hiện:**  
1. Truy vấn `bondInfo[_user]` để lấy tổng số tiền đã gửi.  
2. Trả về tổng số tiền đó.  



### 2.3 `getWithdrawableAmount`
**Mô tả:**  
Xem số lượng token mà người dùng có thể rút tại thời điểm hiện tại.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_user` | Địa chỉ người dùng |

**Output:**  
- Số lượng token có thể rút.

**Công thức:**  

![image](https://github.com/user-attachments/assets/67743b3b-97c9-4af5-8a37-095a322f92b5)

**Các công việc thực hiện:**  
1. Tính toán phần trăm vesting hiện tại.  
2. Tính số token có thể rút theo công thức.  
3. Trả về số lượng có thể rút.  



### 2.4 `getClaimedAmount`
**Mô tả:**  
Xem số lượng token mà người dùng đã rút.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_user` | Địa chỉ người dùng |

**Output:**  
- Số lượng token đã rút.

**Các công việc thực hiện:**  
1. Truy vấn `bondInfo[_user]`.  
2. Trả về tổng số lượng token đã rút.  

## 3. Thông tin về bond

### 3.1 `bondPrice`
**Mô tả:**  
Trả về giá bond tại thời điểm hiện tại.

**Input:**  
- Không có.

**Output:**  
- Giá bond hiện tại.

**Các công việc thực hiện:**  
1. Trả về giá bond dựa trên cơ chế định giá của hợp đồng.  



### 3.2 `getPayout`
**Mô tả:**  
Tính toán số token mà người dùng nhận được khi mua bond.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_amount` | Số lượng USDT sử dụng để mua bond |

**Output:**  
- Số lượng token THORN nhận được.

**Công thức:**  

![image](https://github.com/user-attachments/assets/9ee557f9-dff4-4c12-8921-2eb8238b3015)

**Các công việc thực hiện:**  
1. Lấy tỷ lệ quy đổi.  
2. Tính số lượng THORN nhận được theo công thức.  
3. Trả về giá trị đó.  



### 3.3 `getPayoutRate`
**Mô tả:**  
Trả về tỷ lệ quy đổi giữa USDT và THORN trong Private Sale.

**Input:**  
- Không có.

**Output:**  
- Tỷ lệ quy đổi.

**Các công việc thực hiện:**  
1. Truy xuất tỷ lệ quy đổi từ cấu hình hợp đồng.  
2. Trả về giá trị đó.  



### 3.4 `getThornPrice`
**Mô tả:**  
Trả về giá token THORN tại thời điểm hiện tại.

**Input:**  
- Không có.

**Output:**  
- Giá của THORN.

**Các công việc thực hiện:**  
1. Lấy giá THORN từ biến lưu trữ trong hợp đồng.  
2. Trả về giá trị đó.  



### 3.5 `getBondInfo`
**Mô tả:**  
Trả về thông tin về bond của một địa chỉ cụ thể.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_user` | Địa chỉ người dùng |

**Output:**  
- Thông tin về bond bao gồm tổng số USDT đã gửi, số lượng THORN đã mua, số THORN đã rút, và số THORN còn có thể rút.

**Các công việc thực hiện:**  
1. Truy vấn `bondInfo[_user]`.  
2. Trả về toàn bộ thông tin bond của `_user`.  



### 3.6 `getMaxPayout`
**Mô tả:**  
Trả về số lượng tối đa mà một người có thể nhận được từ Private Sale.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_user` | Địa chỉ người dùng |

**Output:**  
- Số lượng tối đa THORN có thể nhận.

**Công thức:**  
![image](https://github.com/user-attachments/assets/8db7607f-a22d-4e78-b70e-8a7cda3efe16)


**Các công việc thực hiện:**  
1. Tính toán giới hạn mua dựa trên tổng số THORN phân bổ.  
2. Trả về số lượng tối đa có thể nhận.  

## 4. Quản lý hợp đồng


### 4.1 `withdrawStuckAmount`
**Mô tả:**  
Cho phép admin rút số lượng token bị kẹt khỏi hợp đồng.

**Input:**
| Parameter | Meaning |
|-----------|---------|
| `_amount` | Số lượng token muốn rút |
| `_tokenAddress` | Địa chỉ của token muốn rút |

**Output:**  
- Không có.

**Các công việc thực hiện:**  
1. Kiểm tra quyền admin.  
2. Chuyển số lượng token bị kẹt về ví admin.  
3. Gửi sự kiện `StuckAmountWithdrawn`.  

### PrivateSaleRoundThree
#### Tương tự Round 1
### PrivateSaleRoundFour
#### Tương tự Round 1
### Policy
#### PolicyUpgradeable

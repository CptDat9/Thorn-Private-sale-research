# Thorn-private-sale Research
## Tìm hiểu về private sale
 - Private sale là giai đoạn huy động vốn đầu tiên của một dự án crypto, trong đó token được bán riêng cho các nhà đầu tư giàu có, quỹ đầu tư mạo hiểm, tổ chức tài chính,...
 - Đây là giai đoạn kín, với giá token ưu đãi hơn so với vòng công khai, nhưng đi kèm với điều kiện như thời gian khóa token (lock-up period - khoảng thời gian không thể giao dịch hay chuyển nhượng) và lịch phát hành (vesting schedule)
 - Vesting có 2 kiểu phổ biến: Cliff vesting và Linear vesting (Thorn Presale theo kiểu Cliff vesting), Cliff Vesting có 1 khoảng thời gian đóng sau khi phát hành token và sau đó sẽ phát hành token theo lịch trình đã định.
## Cơ chế hoạt động
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
#### PolicyUpgradeable
### Các use-case quan trọng
#### BondDepository
### Công thức sử dụng
### Các hàm quan trọng và ý nghĩa
| Function Name | Function Signature | Meanning |
| ------------- | ------------------ | --------------------- |
| initialize  | initialize(address,address) |  |
| pause  | pause() |  |
| unpauseContract  | unpauseContract() |  |
| initializeBondTerms  | initializeBondTerms(uint256,uint256,uint256,uint256,uint256,uint256,uint256) |  | 
| setBondTerms  | setBondTerms(uint8,uint256) |  |
| setStaking  | setStaking(address,bool) |  |
| setThornAddress  | setThornAddress(address) |  |
| setPrincipleAddress  | setPrincipleAddress(address) |  |
| setWhitelist  | setWhitelist(address[]) |  |
| toggleWhitelisted  | toggleWhitelisted(address) |  |
| withdrawStuckAmount  | withdrawStuckAmount(uint256,address) |  |
| deposit  | deposit(uint256,uint256,address) |  |
| redeem  | redeem(address) |  |
| getAssetPrice  | getAssetPrice(address) |  |
| getPayout  | getPayout(uint256) |  |
| getPayoutRate  | getPayoutRate() |  |
| bondPrice  | bondPrice() |  |
| bondPriceInUSD  | bondPriceInUSD() |  |
| percentToVestFor  | percentToVestFor(address) |  |
| getBondInfo  | getBondInfo(address) |   |
| getWhitelist  | getWhitelist() |  |
| getWhitelistStatus  | getWhitelistStatus(address) |  |
| getThornPrice  | getThornPrice() |  |
| getWithdrawableAmount  | getWithdrawableAmount(address) |  |
#### ThornERC20
| Function Name |  Function Signature | Meaning |
| ------------- |  ------------------ | ------------------ |
| mint | mint(address,uint256) | |
| burn | burn(uint256) | |
| burnFrom | burnFrom(address,uint256) | |
| _burnFrom | _burnFrom(address,uint256) | |
#### TokenPrice
##### Công thức sử dụng

| Function Name | Function Signature | Meaning | 
| ------------- | ---------- | ------------------ | 
| setAaveOracle | setAaveOracle(address) | |
| setSupportTokenOraclePrice |  setSupportTokenOraclePrice(address,bool) | |
| getLpToken |  getLpToken(address) | |
| setLpTokens |  setLpTokens(address,(address,address)) | |
| getAssetPrice | getAssetPrice(address) | |

#### Treasury
| Function Name  | Function Signature | Meaning |
| -------------  | ------------------ | ------- |
| deposit  | deposit(uint256,address,uint256) | |
| manage  | manage(address,uint256) | |
| mintRewards  | mintRewards(address,uint256) | |
| excessReserves | excessReserves() | |
| auditReserves  | auditReserves() | |
| valueOf  | valueOf(address,uint256) | |
| queue  | queue(uint8,address) | |
| toggle  | toggle(uint8,address,address) | |
#### PrivateSaleRoundOne
### Công thức sử dụng
### Các hàm quan trọng và ý nghĩa
| Function Name | Function Signature | Meaning | 
| ---------- | ------ | ----------------- | 
| initializePrivateSaleRound |  initializePrivateSaleRound(uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256) |
| setPrivateSale | setPrivateSale(uint8,uint256) | |
| setThornPrice |  setThornPrice(uint256) | |
| setThornAddress | setThornAddress(address) | |
| setUsdtAddress | setUsdtAddress(address) | |
| withdrawStuckAmount | withdrawStuckAmount(uint256,address) | |
| toggleWhitelisted | toggleWhitelisted(address) | |
| toggleUseWhiteList | toggleUseWhiteList() | |
| deposit | deposit(uint256,address) | |
| redeem | redeem(address) | |
| percentVestedFor | percentVestedFor(address) | |
| getTotalReceived | getTotalReceived(address) | |
| bondPrice | bondPrice() | |
| getPayout | getPayout(uint256) | |
| getPayoutRate | getPayoutRate() | |
| getThornPrice | getThornPrice() | |
| getWithdrawableAmount | getWithdrawableAmount(address) | |
| getClaimedAmount | getClaimedAmount(address) | |
| getBondInfo | getBondInfo(address) | |
| getMaxPayout | getMaxPayout(address) | |
#### PrivateSaleRoundThree
##### Tương tự Round 1
#### PrivateSaleRoundFour
##### Tương tự Round 1
#### Policy
#### PolicyUpgradeable

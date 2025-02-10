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
- Nắm giữ và quản lí tài sản của dự án.
#### PrivateSaleRoundOne
- Quản lí vòng Presale
#### PrivateSaleRoundThree
- Quản lí vòng Presale
#### PrivateSaleRoundFour
- Quản lí vòng Presale
#### Policy
- Quản trị dự án (kiểm soát người tài khoản nắm quyền quản lí chính sách dự án)
#### PolicyUpgradeable
- Proxy của Policy.
## Thiết kế contract
### Các thuộc tính quan trọng
#### BondDepository
##### Thuộc tính:
- `staking`: Địa chỉ của contract staking để tự dộng stake phần thưởng bond.
- `stakingHelper`: Địa chỉ của contract giúp stake và claim khi không có warmup staking
- `Thorn`: Địa chỉ của token Thorn, được trả khi mua bond.
- `principle`: Địa chỉ của token được sử dụng để tạo bond.
- `terms`: Terms(struct) chứa thông tin điều khoản cho bond mới.
- `bondInfo`:	Mapping lưu trữ thông tin bond của từng địa chỉ depositor.
- `totalDebt`:	Tổng giá trị các bond chưa thanh toán, dùng để tính giá bond.
- `whitelisted`:	Mapping lưu trữ trạng thái whitelist của từng địa chỉ.
- `whitelist`	Mảng lưu trữ danh sách các địa chỉ đã được whitelist.
 - P/s: Whitelist: danh sách địa chỉ được phép tham gia vào sự kiện.
- Struct
- Terms:
- `buyingTimeStart`:	Thời điểm bắt đầu cho phép mua bond.
- `buyingTime`:	Thời gian cho phép mua bond tính từ buyingTimeStart.
- `vestingTerm`:	Số block cần chờ để vesting bond.
- `maxPayout`:	Tỷ lệ phần trăm tối đa (đơn vị thousandths) của tổng supply có thể được tạo thành bond.
- `maxDebt`:	Tổng nợ tối đa được tạo ra từ bond.
- `discountRatio`:	Tỷ lệ giảm giá khi mua bond.
- `minimumThorn`:	Giá tối thiểu của token Thorn.
- Bond:
- `totalBought`:	Tổng lượng Thorn đã mua qua bond của depositor.
- `payout`:	Số lượng Thorn còn lại để trả cho depositor.
- `vesting`:	Số block còn lại để vesting hoàn tất.
- `lastBlock`:	Block cuối cùng depositor tương tác với bond.
- `pricePaid`:	Giá đã thanh toán bằng DAI khi mua bond.
#### ThornERC20
- 
#### TokenPrice
-
#### Treasury
#### PrivateSaleRoundOne
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

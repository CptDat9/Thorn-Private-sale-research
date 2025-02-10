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
-  Suy ra, Giá bond `Pa` tại thời điểm a tỉ lệ thuận với tỉ số giữa thời gian còn lại `Ta` và số token còn lại tại thời điểm a  là `Ca`.
#### ThornERC20
- Contract token ERc20 của Thorn.
#### TokenPrice
- Quản lí giá token theo thời gian hoặc sự kiện.
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
#### PrivateSaleRoundFour
#### Policy
#### PolicyUpgradeable
### Các use-case quan trọng
#### BondDepository
#### ThornERC20
#### TokenPrice
#### Treasury
#### PrivateSaleRoundOne
#### PrivateSaleRoundThree
#### PrivateSaleRoundFour
#### Policy
#### PolicyUpgradeable

//
//  fingerUserInfo.h
//  finger
//
//  Created by wondriver on 2022/04/21.
//  Copyright © 2022 wondriver. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface fingerUserInfo : NSObject

@property (nonatomic, copy) NSString* adid;
@property (nonatomic, copy) NSString* gender;
@property (nonatomic, copy) NSString* age;
@property (nonatomic, copy) NSString* grade;
@property (nonatomic, copy) NSString* identity;
@property (nonatomic, copy) NSString* birth_date;
@property (nonatomic, copy) NSString* device_model;
@property (nonatomic, copy) NSString* ischild;
@property (nonatomic, copy) NSString* job;
@property (nonatomic, copy) NSString* login_date;
@property (nonatomic, copy) NSString* marriage_date;
@property (nonatomic, copy) NSString* mileage;
@property (nonatomic, copy) NSString* point;
@property (nonatomic, copy) NSString* signup_date;
@property (nonatomic, copy) NSString* adagappush;
@property (nonatomic, copy) NSString* adagemail;
@property (nonatomic, copy) NSString* adagtext;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* hp;
@property (nonatomic, copy) NSString* area;
@property (nonatomic, copy) NSString* url;
@property (nonatomic, copy) NSString* etc0;
@property (nonatomic, copy) NSString* etc1;
@property (nonatomic, copy) NSString* etc2;
@property (nonatomic, copy) NSString* etc3;
@property (nonatomic, copy) NSString* etc4;
@property (nonatomic, copy) NSString* etc5;

@end


/*
 adid           광고아이디, 40글자 이하            X
 gender          성별, 숫자 : 0 여성, 1 남성            O
 age             나이, 숫자 : 1 ~ 200            O
 grade           회원등급, 숫자 : 1 ~10            O
 identity         핑거푸시 식별자, 50글자 이하            O
 birth_date     생년월일 2022-04-14, 10 글자 이하            O
 device_model    단말기 모델, 20글자 이하            O
 ischild         자녀유무 0 없음, 1 있음            X
 job            직업, TBL_JOB.idx            X
 login_date     로그인 시간 (20209-11 10:23:01), 19자리            X
 marriage_date  결혼기념일 (2021-09-11)            O
 mileage        마일리지 0 ~ 2000000000            X
 point          포인트, -2000000000 ~ 2000000000            X
 signup_date    로그인날자 (2022-04-14) , 10자리            X
 adagappush    광고 앱푸시 동의여부 0 / 1            X
 adagemail      광고 이메일 수신 동의 여부 0 / 1            X
 adagtext       광고 문자수신 동의 여부 0 / 1            X
 email          이메일            O
 hp             핸드폰            O
 area           지역번호            X
 url            url            X
 etc0           숫자형, -2000000000 ~ 2000000000            X
 etc1           숫자형, -2000000000 ~ 2000000001            X
 etc2          숫자형, -2000000000 ~ 2000000002            X
 etc3           문자형, 20글자 이하            X
 etc4           문자형, 20글자 이하            X
 etc5          문자형, 20글자 이하            X
 */


NS_ASSUME_NONNULL_END

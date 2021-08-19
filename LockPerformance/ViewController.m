//
//  ViewController.m
//  LockPerformance
//
//  Created by 路文汉 on 2021/8/19.
//
#define KCLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);

#import "ViewController.h"
#import <libkern/OSAtomic.h>
#import <pthread/pthread.h>
#import <os/lock.h>
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int kc_runTimes = 100000;
    /** OSSpinLock 性能 */
    {
        OSSpinLock kc_spinlock = OS_SPINLOCK_INIT;
        double_t kc_beginTime = CFAbsoluteTimeGetCurrent();
        for (int i=0 ; i < kc_runTimes; i++) {
            OSSpinLockLock(&kc_spinlock);          //解锁
            OSSpinLockUnlock(&kc_spinlock);
        }
        double_t kc_endTime = CFAbsoluteTimeGetCurrent() ;
        KCLog(@"OSSpinLock: %f ms",(kc_endTime - kc_beginTime)*1000);
    }
    
    /** dispatch_semaphore_t 性能 */
    {
        dispatch_semaphore_t kc_sem = dispatch_semaphore_create(1);
        double_t kc_beginTime = CFAbsoluteTimeGetCurrent();
        for (int i=0 ; i < kc_runTimes; i++) {
            dispatch_semaphore_wait(kc_sem, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_signal(kc_sem);
        }
        double_t kc_endTime = CFAbsoluteTimeGetCurrent() ;
        KCLog(@"dispatch_semaphore_t: %f ms",(kc_endTime - kc_beginTime)*1000);
    }
    
    /** os_unfair_lock_lock 性能 */
    {
        os_unfair_lock kc_unfairlock = OS_UNFAIR_LOCK_INIT;
        double_t kc_beginTime = CFAbsoluteTimeGetCurrent();
        for (int i=0 ; i < kc_runTimes; i++) {
            os_unfair_lock_lock(&kc_unfairlock);
            os_unfair_lock_unlock(&kc_unfairlock);
        }
        double_t kc_endTime = CFAbsoluteTimeGetCurrent() ;
        KCLog(@"os_unfair_lock_lock: %f ms",(kc_endTime - kc_beginTime)*1000);
    }
    
    
    /** pthread_mutex_t 性能 */
    {
        pthread_mutex_t kc_metext = PTHREAD_MUTEX_INITIALIZER;
      
        double_t kc_beginTime = CFAbsoluteTimeGetCurrent();
        for (int i=0 ; i < kc_runTimes; i++) {
            pthread_mutex_lock(&kc_metext);
            pthread_mutex_unlock(&kc_metext);
        }
        double_t kc_endTime = CFAbsoluteTimeGetCurrent() ;
        KCLog(@"pthread_mutex_t: %f ms",(kc_endTime - kc_beginTime)*1000);
    }
    
    
    /** NSlock 性能 */
    {
        NSLock *kc_lock = [NSLock new];
        double_t kc_beginTime = CFAbsoluteTimeGetCurrent();
        for (int i=0 ; i < kc_runTimes; i++) {
            [kc_lock lock];
            [kc_lock unlock];
        }
        double_t kc_endTime = CFAbsoluteTimeGetCurrent() ;
        KCLog(@"NSlock: %f ms",(kc_endTime - kc_beginTime)*1000);
    }
    
    /** NSCondition 性能 */
    {
        NSCondition *kc_condition = [NSCondition new];
        double_t kc_beginTime = CFAbsoluteTimeGetCurrent();
        for (int i=0 ; i < kc_runTimes; i++) {
            [kc_condition lock];
            [kc_condition unlock];
        }
        double_t kc_endTime = CFAbsoluteTimeGetCurrent() ;
        KCLog(@"NSCondition: %f ms",(kc_endTime - kc_beginTime)*1000);
    }

    /** PTHREAD_MUTEX_RECURSIVE 性能 */
    {
        pthread_mutex_t kc_metext_recurive;
        pthread_mutexattr_t attr;
        pthread_mutexattr_init (&attr);
        pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init (&kc_metext_recurive, &attr);
        
        double_t kc_beginTime = CFAbsoluteTimeGetCurrent();
        for (int i=0 ; i < kc_runTimes; i++) {
            pthread_mutex_lock(&kc_metext_recurive);
            pthread_mutex_unlock(&kc_metext_recurive);
        }
        double_t kc_endTime = CFAbsoluteTimeGetCurrent() ;
        KCLog(@"PTHREAD_MUTEX_RECURSIVE: %f ms",(kc_endTime - kc_beginTime)*1000);
    }
    
    /** NSRecursiveLock 性能 */
    {
        NSRecursiveLock *kc_recursiveLock = [NSRecursiveLock new];
        double_t kc_beginTime = CFAbsoluteTimeGetCurrent();
        for (int i=0 ; i < kc_runTimes; i++) {
            [kc_recursiveLock lock];
            [kc_recursiveLock unlock];
        }
        double_t kc_endTime = CFAbsoluteTimeGetCurrent() ;
        KCLog(@"NSRecursiveLock: %f ms",(kc_endTime - kc_beginTime)*1000);
    }
    

    /** NSConditionLock 性能 */
    {
        NSConditionLock *kc_conditionLock = [NSConditionLock new];
        double_t kc_beginTime = CFAbsoluteTimeGetCurrent();
        for (int i=0 ; i < kc_runTimes; i++) {
            [kc_conditionLock lock];
            [kc_conditionLock unlock];
        }
        double_t kc_endTime = CFAbsoluteTimeGetCurrent() ;
        KCLog(@"NSConditionLock: %f ms",(kc_endTime - kc_beginTime)*1000);
    }

    /** @synchronized 性能 */
    {
        double_t kc_beginTime = CFAbsoluteTimeGetCurrent();
        for (int i=0 ; i < kc_runTimes; i++) {
            @synchronized(self) {}
        }
        double_t kc_endTime = CFAbsoluteTimeGetCurrent() ;
        KCLog(@"@synchronized: %f ms",(kc_endTime - kc_beginTime)*1000);
    }


}


@end

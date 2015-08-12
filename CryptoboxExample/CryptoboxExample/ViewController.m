//
//  ViewController.m
//  CryptoboxExample
//
//  Created by Andreas Kompanez on 04.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import "ViewController.h"

#import "cbox.h"

#import "CryptoboxiOS/Cryptobox.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self executeBasicTests];
    [self executeCryptoboxTests];
}

- (void)executeCryptoboxTests
{
    NSError *error = nil;
    CBCryptoBox *aliceBox = [CBCryptoBox cryptoBoxWithPathURL:CBCreateTemporaryDirectoryAndReturnURL() error:&error];
    NSAssert(error == nil, @"error");
    NSAssert(aliceBox, @"alice box init failed");
    
    CBCryptoBox *bobBox = [CBCryptoBox cryptoBoxWithPathURL:CBCreateTemporaryDirectoryAndReturnURL() error:&error];
    NSAssert(error == nil, @"error");
    NSAssert(bobBox, @"bob box init failed");
    
    
    NSArray *preKeys = [bobBox generatePreKeys:(NSRange){0, 1} error:&error];
    NSAssert(error == nil, @"error");
    NSAssert(preKeys.count == 1, @"failed at prekey generation");
    
    CBPreKey *bobPreKey = preKeys[0];
    NSAssert([bobPreKey isKindOfClass:[CBPreKey class]], @"Wrong class for pre key");
    
    CBSession *alice = [bobBox sessionWithId:@"alice" preKey:bobPreKey error:&error];
    NSAssert(error == nil, @"error");
    NSAssert(alice, @"Failed at init alice session");
    
    
    BOOL result = [alice save:&error];
    NSAssert(error == nil, @"error");
    NSAssert(result == YES, @"session save failed");
    
    NSData *helloBobMessageData = [@"Hello Bob" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [alice encrypt:helloBobMessageData error:&error];
    
    // TODO: finish this
}

- (void)executeBasicTests
{
    NSURL *urlA = CBCreateTemporaryDirectoryAndReturnURL();
    NSURL *urlB = CBCreateTemporaryDirectoryAndReturnURL();

    NSAssert(urlA != nil, @"");
    NSAssert(urlB != nil, @"");
    
    char const * alice_dir = [[urlA path] UTF8String];
    char const * bob_dir = [[urlB path] UTF8String];

    printf("alice=\"%s\", bob=\"%s\"\n", alice_dir, bob_dir);
    
    CBoxResult rc = CBOX_SUCCESS;
    
    CBox * alice_box = NULL;
    rc = cbox_file_open(alice_dir, &alice_box);
    assert(rc == CBOX_SUCCESS);
    assert(alice_box != NULL);
    
    CBox * bob_box = NULL;
    rc = cbox_file_open(bob_dir, &bob_box);
    assert(rc == CBOX_SUCCESS);
    assert(bob_box != NULL);
    
    test_basics(alice_box, bob_box);
    test_prekey_removal(alice_box, bob_box);
    test_random_bytes(alice_box);
    test_last_prekey(alice_box, bob_box);
    test_duplicate_msg(alice_box, bob_box);
    test_delete_session(alice_box, bob_box);
    
    // Cleanup
    cbox_close(alice_box);
    cbox_close(bob_box);
}

static void test_basics(CBox * alice_box, CBox * bob_box) {
    printf("test_basics ... ");
    
    CBoxResult rc = CBOX_SUCCESS;
    
    // Bob prekey
    CBoxVec * bob_prekey = NULL;
    rc = cbox_new_prekey(bob_box, 1, &bob_prekey);
    assert(rc == CBOX_SUCCESS);
    
    // Alice
    CBoxSession * alice = NULL;
    rc = cbox_session_init_from_prekey(alice_box, "alice", cbox_vec_data(bob_prekey), cbox_vec_len(bob_prekey), &alice);
    assert(rc == CBOX_SUCCESS);
    rc = cbox_session_save(alice);
    assert(rc == CBOX_SUCCESS);
    uint8_t const hello_bob[] = "Hello Bob!";
    CBoxVec * cipher = NULL;
    rc = cbox_encrypt(alice, hello_bob, sizeof(hello_bob), &cipher);
    assert(rc == CBOX_SUCCESS);
    assert(strncmp((char const *) hello_bob, (char const *) cbox_vec_data(cipher), cbox_vec_len(cipher)) != 0);
    
    // Bob
    CBoxSession * bob = NULL;
    CBoxVec * plain = NULL;
    rc = cbox_session_init_from_message(bob_box, "bob", cbox_vec_data(cipher), cbox_vec_len(cipher), &bob, &plain);
    assert(rc == CBOX_SUCCESS);
    cbox_session_save(bob);
    assert(strncmp((char const *) hello_bob, (char const *) cbox_vec_data(plain), cbox_vec_len(plain)) == 0);
    
    // Compare fingerprints
    CBoxVec * local = NULL;
    CBoxVec * remote = NULL;
    
    cbox_fingerprint_local(alice_box, &local);
    cbox_fingerprint_remote(bob, &remote);
    assert(strncmp((char const *) cbox_vec_data(local), (char const *) cbox_vec_data(remote), cbox_vec_len(remote)) == 0);
    cbox_vec_free(remote);
    cbox_vec_free(local);
    
    cbox_fingerprint_local(bob_box, &local);
    cbox_fingerprint_remote(alice, &remote);
    assert(strncmp((char const *) cbox_vec_data(local), (char const *) cbox_vec_data(remote), cbox_vec_len(remote)) == 0);
    cbox_vec_free(remote);
    cbox_vec_free(local);
    
    // Load the sessions again
    cbox_session_close(alice);
    cbox_session_close(bob);
    rc = cbox_session_get(alice_box, "alice", &alice);
    assert(rc == CBOX_SUCCESS);
    rc = cbox_session_get(bob_box, "bob", &bob);
    assert(rc == CBOX_SUCCESS);
    
    // Cleanup
    cbox_vec_free(cipher);
    cbox_vec_free(plain);
    cbox_vec_free(bob_prekey);
    
    cbox_session_close(alice);
    cbox_session_close(bob);
    
    printf("OK\n");
}

static void test_prekey_removal(CBox * alice_box, CBox * bob_box) {
    printf("test_prekey_removal ... ");
    CBoxResult rc = CBOX_SUCCESS;
    
    // Bob prekey
    CBoxVec * bob_prekey = NULL;
    rc = cbox_new_prekey(bob_box, 1, &bob_prekey);
    assert(rc == CBOX_SUCCESS);
    
    // Alice
    CBoxSession * alice = NULL;
    rc = cbox_session_init_from_prekey(alice_box, "alice", cbox_vec_data(bob_prekey), cbox_vec_len(bob_prekey), &alice);
    assert(rc == CBOX_SUCCESS);
    uint8_t const hello_bob[] = "Hello Bob!";
    CBoxVec * cipher = NULL;
    rc = cbox_encrypt(alice, hello_bob, sizeof(hello_bob), &cipher);
    assert(rc == CBOX_SUCCESS);
    
    // Bob
    CBoxSession * bob = NULL;
    CBoxVec * plain = NULL;
    rc = cbox_session_init_from_message(bob_box, "bob", cbox_vec_data(cipher), cbox_vec_len(cipher), &bob, &plain);
    assert(rc == CBOX_SUCCESS);
    
    // Pretend something happened before Bob could save his session and he retries.
    // The prekey should not be removed (yet).
    cbox_session_close(bob);
    cbox_vec_free(plain);
    rc = cbox_session_init_from_message(bob_box, "bob", cbox_vec_data(cipher), cbox_vec_len(cipher), &bob, &plain);
    assert(rc == CBOX_SUCCESS);
    
    cbox_session_save(bob);
    
    // Now the prekey should be gone
    cbox_session_close(bob);
    cbox_vec_free(plain);
    rc = cbox_session_init_from_message(bob_box, "bob", cbox_vec_data(cipher), cbox_vec_len(cipher), &bob, &plain);
    assert(rc == CBOX_INVALID_MESSAGE);
    
    // Cleanup
    cbox_vec_free(bob_prekey);
    cbox_vec_free(cipher);
    cbox_session_close(alice);
    
    printf("OK\n");
}

static void test_random_bytes(CBox const * b) {
    printf("test_random_bytes ... ");
    CBoxVec * random = cbox_random_bytes(b, 16);
    cbox_vec_free(random);
    printf("OK\n");
}

static void test_last_prekey(CBox * alice_box, CBox * bob_box) {
    printf("test_last_prekey ... ");
    CBoxVec * bob_prekey = NULL;
    CBoxResult rc = cbox_new_prekey(bob_box, CBOX_LAST_PREKEY_ID, &bob_prekey);
    assert(rc == CBOX_SUCCESS);
    
    // Alice
    CBoxSession * alice = NULL;
    rc = cbox_session_init_from_prekey(alice_box, "alice", cbox_vec_data(bob_prekey), cbox_vec_len(bob_prekey), &alice);
    cbox_vec_free(bob_prekey);
    assert(rc == CBOX_SUCCESS);
    uint8_t const hello_bob[] = "Hello Bob!";
    CBoxVec * cipher = NULL;
    rc = cbox_encrypt(alice, hello_bob, sizeof(hello_bob), &cipher);
    assert(rc == CBOX_SUCCESS);
    
    // Bob
    CBoxSession * bob = NULL;
    CBoxVec * plain = NULL;
    rc = cbox_session_init_from_message(bob_box, "bob", cbox_vec_data(cipher), cbox_vec_len(cipher), &bob, &plain);
    assert(rc == CBOX_SUCCESS);
    
    cbox_session_save(bob);
    cbox_session_close(bob);
    cbox_vec_free(plain);
    
    // Bob's last prekey is not removed
    rc = cbox_session_init_from_message(bob_box, "bob", cbox_vec_data(cipher), cbox_vec_len(cipher), &bob, &plain);
    assert(rc == CBOX_SUCCESS);
    
    cbox_vec_free(plain);
    cbox_vec_free(cipher);
    cbox_session_close(alice);
    cbox_session_close(bob);
    printf("OK\n");
}

static void test_duplicate_msg(CBox * alice_box, CBox * bob_box) {
    printf("test_duplicate_msg ... ");
    CBoxVec * bob_prekey = NULL;
    CBoxResult rc = cbox_new_prekey(bob_box, 0, &bob_prekey);
    assert(rc == CBOX_SUCCESS);
    
    // Alice
    CBoxSession * alice = NULL;
    rc = cbox_session_init_from_prekey(alice_box, "alice", cbox_vec_data(bob_prekey), cbox_vec_len(bob_prekey), &alice);
    cbox_vec_free(bob_prekey);
    assert(rc == CBOX_SUCCESS);
    uint8_t const hello_bob[] = "Hello Bob!";
    CBoxVec * cipher = NULL;
    rc = cbox_encrypt(alice, hello_bob, sizeof(hello_bob), &cipher);
    assert(rc == CBOX_SUCCESS);
    
    // Bob
    CBoxSession * bob = NULL;
    CBoxVec * plain = NULL;
    rc = cbox_session_init_from_message(bob_box, "bob", cbox_vec_data(cipher), cbox_vec_len(cipher), &bob, &plain);
    assert(rc == CBOX_SUCCESS);
    cbox_vec_free(plain);
    
    rc = cbox_decrypt(bob, cbox_vec_data(cipher), cbox_vec_len(cipher), &plain);
    assert(rc == CBOX_DUPLICATE_MESSAGE);
    
    cbox_vec_free(cipher);
    cbox_session_close(alice);
    cbox_session_close(bob);
    printf("OK\n");
}

static void test_delete_session(CBox * alice_box, CBox * bob_box) {
    printf("test_delete_session ... ");
    CBoxVec * bob_prekey = NULL;
    CBoxResult rc = cbox_new_prekey(bob_box, 0, &bob_prekey);
    assert(rc == CBOX_SUCCESS);
    
    CBoxSession * alice = NULL;
    rc = cbox_session_init_from_prekey(alice_box, "alice", cbox_vec_data(bob_prekey), cbox_vec_len(bob_prekey), &alice);
    cbox_vec_free(bob_prekey);
    assert(rc == CBOX_SUCCESS);
    
    rc = cbox_session_save(alice);
    assert(rc == CBOX_SUCCESS);
    cbox_session_close(alice);
    
    rc = cbox_session_delete(alice_box, "alice");
    assert(rc == CBOX_SUCCESS);
    
    rc = cbox_session_get(alice_box, "alice", &alice);
    assert(rc == CBOX_NO_SESSION);
    
    // no-op, session does not exist
    rc = cbox_session_delete(alice_box, "alice");
    assert(rc == CBOX_SUCCESS);
    printf("OK\n");
}

@end

import http from 'k6/http';
import { check } from 'k6';

const url = 'https://give928.asuscomm.com/';

export const options = {
    // Smoke Test
    vus: 1,
    duration: '1s',

    // Load Test
    /*stages: [
        { duration: '10s', target: 10 },
        { duration: '10s', target: 50 },
        { duration: '10s', target: 100 },
        { duration: '10s', target: 100 },
        { duration: '10s', target: 100 },
        { duration: '10s', target: 50 },
        { duration: '10s', target: 10 }
    ],*/

    // Stress Test
    /*stages: [
        {duration: '10s', target: 10},
        {duration: '10s', target: 100},
        {duration: '10s', target: 300},
        {duration: '10s', target: 500},
        {duration: '10s', target: 500},
        {duration: '10s', target: 300},
        {duration: '10s', target: 10},
    ],*/

    thresholds: {
        http_req_duration: ["p(99)<1500"], // 99% of requests must complete below 1.5s
    },
};

export default function () {
    main();

    const email = generateEmail();
    const password = "1234";
    const age = 30;

    join(email, password, age);

    const accessToken = login(email, password);

    favorite(accessToken);

    path();
};

const main = () => {
    const res = http.get(url);
    check(res, { 'main status was 200': (r) => r.status === 200 });
};

const join = (email, password, age) => {
    const payload = JSON.stringify({
        email: email,
        password: password,
        age: age
    });

    const params = {
        headers: {
            'Content-Type': 'application/json',
        },
    };

    const res = http.post(url + '/members', payload, params);
    check(res, { 'join status was 201': (r) => r.status === 201 });
};

const login = (email, password) => {
    const payload = JSON.stringify({
        email: email,
        password: password
    });

    const params = {
        headers: {
            'Content-Type': 'application/json',
        },
    };

    const res = http.post(url + '/login/token', payload, params);
    check(res, { 'login status was 200': (r) => r.status === 200 });

    return res.json('accessToken');
};

const favorite = (accessToken) => {
    const params = {
        headers: {
            'Authorization': 'Bearer ' + accessToken,
        },
    };

    const res = http.get(url + '/favorites', params);
    check(res, { 'favorite status was 200': (r) => r.status === 200 });
};

const path = () => {
    const res = http.get(url + '/paths?source=113&target=173');
    check(res, { 'path status was 200': (r) => r.status === 200 });
};

const generateEmail = () => {
    return uuid() + "@test.com"
};

const uuid = () => {
    return 'xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
        const r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
};

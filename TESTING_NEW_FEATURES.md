# New Feature Testing Checklist

## 1. Refill Reminders
- [ ] Add or edit a medicine → toggle "Recurring" on → set interval (e.g. 30 days)
- [ ] Reopen the medicine → toggle and interval should still be there
- [ ] Actual reminder only fires via the daily server cron job — trigger it manually or wait for it to run to see the notification

## 2. Centers-Need Banner
- [ ] Confirm your profile has a saved location
- [ ] Confirm at least one nearby medical center has an inventory category set to "accepting" (check vendor dashboard or DB)
- [ ] Open Medicine Inventory screen → banner should show "X centers near you accepting donations"
- [ ] Tap banner → should open the Location screen
- [ ] Tap X on banner → should dismiss for that session
- [ ] No banner should appear if no nearby center has anything "accepting"

## 3. Family Profiles
- [ ] Go to Manage Family → add a member (e.g. "Mom")
- [ ] Add a medicine and assign it to "Mom" in the picker
- [ ] Inventory screen → profile chips ("Self", "Mom") should appear at top
- [ ] Tap "Mom" chip → should filter to only her medicines
- [ ] Delete "Mom" from Manage Family → her medicine should fall back under "Self"

## 4. Impact Card
- [ ] Go to Profile → My Impact
- [ ] Tap "Share my Impact"
- [ ] Share sheet should open with a PNG showing name, disposed count, tracked/campaign stats, and earned badges

// Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE_ODID file.
// Based on SharedPreferencesListEncoder.java originally written by
// Copyright 2013 The Flutter Authors.

/**
 * An interface used to provide conversion logic between Array<string> and string for
 * SharedPreferencesPlugin.
 */
export interface SharedPreferencesListEncoder {
  /** Converts list to String for storing in shared preferences. */
  encode(list: Array<string>): string;
  /** Converts stored String representing List<String> to List. */
  decode(listString: string): ESObject;
}